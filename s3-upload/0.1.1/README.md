# s3-upload

A task to upload arbitrary, unversioned objects to S3.

## Usage

```yaml
- task: s3-upload
  file: common-tasks-repo/s3-upload/latest/s3-upload.yml
  input-mapping:
    source: some-interesting-volume
  params:
    source_glob: source/somewhere/*.jar
    destination: s3://some-bucket/some-folder/my-project
    overwrite: false
```

`source_glob` will accept any `bash` compliant glob.

> ### :heavy_exclamation_mark: Caveat Emptor
>
> Be careful not to add dots or trailing slashes to your destination.
>
> The following _may cause unexpected results_ :
>
> - `s3://my-bucket/`
> - `s3://my-bucket/.`
>
> S3 is not a POSIX compliant file system!

## License

> Copyright AdGear | Samsung Ads
