npm run build

gut add dist -f

git commit -m "deploy"

git subtree push --prefix dist origin gh-pages