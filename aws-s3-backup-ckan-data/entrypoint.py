#!/usr/bin/env python
import os
import datetime
import tempfile
import subprocess
import zipfile
from zipfile import ZipFile
from urllib.parse import urlparse

from minio import Minio


TARGET_BUCKET_PATH = os.environ.get('TARGET_BUCKET_PATH')
S3_FILESTORE_AWS_ACCESS_KEY_ID = os.environ.get('S3_FILESTORE_AWS_ACCESS_KEY_ID')
S3_FILESTORE_AWS_BUCKET_NAME = os.environ.get('S3_FILESTORE_AWS_BUCKET_NAME')
S3_FILESTORE_AWS_HOST_NAME = os.environ.get('S3_FILESTORE_AWS_HOST_NAME')
S3_FILESTORE_AWS_REGION_NAME = os.environ.get('S3_FILESTORE_AWS_REGION_NAME')
S3_FILESTORE_AWS_SECRET_ACCESS_KEY = os.environ.get('S3_FILESTORE_AWS_SECRET_ACCESS_KEY')


def main():
    assert TARGET_BUCKET_PATH, 'missing TARGET_BUCKET_PATH'
    assert all((S3_FILESTORE_AWS_ACCESS_KEY_ID,
                S3_FILESTORE_AWS_BUCKET_NAME,
                S3_FILESTORE_AWS_HOST_NAME,
                S3_FILESTORE_AWS_REGION_NAME,
                S3_FILESTORE_AWS_SECRET_ACCESS_KEY)), 'S3_FILESTORE env vars are missing'
    minio = Minio(
        endpoint=urlparse(S3_FILESTORE_AWS_HOST_NAME).hostname,
        region=S3_FILESTORE_AWS_REGION_NAME,
        access_key=S3_FILESTORE_AWS_ACCESS_KEY_ID,
        secret_key=S3_FILESTORE_AWS_SECRET_ACCESS_KEY,
        secure=urlparse(S3_FILESTORE_AWS_HOST_NAME).scheme == 'https'
    )
    assert minio.bucket_exists(S3_FILESTORE_AWS_BUCKET_NAME), 'bucket does not exist'
    now = datetime.datetime.now().strftime('%Y-%m-%dT%H-%M-%S')
    with tempfile.TemporaryDirectory() as tmpdir:
        with ZipFile(os.path.join(tmpdir, '{}.zip'.format(now)), mode='w',
                     compression=zipfile.ZIP_DEFLATED,
                     compresslevel=9) as zf:
            for obj in minio.list_objects(S3_FILESTORE_AWS_BUCKET_NAME, recursive=True):
                print(obj.object_name)
                minio.fget_object(
                    S3_FILESTORE_AWS_BUCKET_NAME,
                    obj.object_name,
                    os.path.join(tmpdir, 'file.data')
                )
                zf.write(os.path.join(tmpdir, 'file.data'), obj.object_name)
        subprocess.check_call(['ls', '-lah', os.path.join(tmpdir, '{}.zip'.format(now))])
        subprocess.check_call([
            'aws', 's3', 'cp',
            os.path.join(tmpdir, '{}.zip'.format(now)),
            's3://{}/{}.zip'.format(TARGET_BUCKET_PATH, now)
        ])


if __name__ == "__main__":
    main()
