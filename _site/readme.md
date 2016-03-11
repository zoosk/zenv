# ZENv Static Website

## Dev Mode

* [Read docs about jekyl here.](https://jekyllrb.com/docs/home/)
* To serve in dev mode: `jekyll serve --baseurl ""`
* This will automatically build your HTML and SASS css files.
* View the page on localhost:4000

## Deploying

After you're satisfied:
```
jekyll build
cp _sites/css/* css/*
git add .
git commit -m "comment"
git push origin gh-pages
```
Not sure why, but you need to copy the css file from the _sites directory into the base directory.

## Notes

* _config.yml has commented out parameters to deploy to our internal GitHub