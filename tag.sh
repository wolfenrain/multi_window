package=$1

if [ ! -d $package ] || [ -z $package ]; then
    echo "Package '$package' not found"
    exit 1
fi

version=$(yq e '.version' "./${package}/pubspec.yaml")

echo "Tagging v${version} for '$package'"
git tag -a ${package}-v${version} -m 'v${version}'

echo "Pushing v${version} for '$package'"
git push origin ${package}-v${version}