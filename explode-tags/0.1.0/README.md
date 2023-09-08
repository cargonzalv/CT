# explode-tags

This task takes an input file with a semver compliant version and explodes the
value in fuzzily pinnable tags.

Given the tag `1.2.3`, this image will produce the following files :

- `tags/tags.bare` : `1.2.3`
- `tags/tags.additional` : `1 1.2`

This is meant to be consumed by the Concourse Docker image resource to have an
image with several tags, some of which floating tags.

So given an image tagged `1.2.3`, one could get the same image with :

- `1`
- `1.2`
- `1.2.3`

... until a new version is released.

## Usage

```yaml
# This is our task
- task: explode-tags
  file: common-tasks-repo/explode-tags/latest/explode-tags.yml
  input-mapping:
    source: some-interesting-volume
  params:
    version_file: source/somefolder/version.file

# And we consume the result here
- put: some-docker-image-resource
  params:
    build: some-interesting-volume/somefolder
    tag_as_latest: true
    tag_file: tags/tags.bare
    additional_tags: tags/tags.additional
```

## Contributing

1.  Create your feature branch: `git checkout -b feature/my-new-feature`
2.  Commit your changes: `git commit -am 'Add some feature'`
3.  Push to the branch: `git push origin my-new-feature`
4.  Submit a pull request :D

## License

> Copyright AdGear | Samsung Ads
