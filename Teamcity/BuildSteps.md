#### 1. Get commit tag
```
git fetch;
commit_tag=$(git tag --points-at HEAD)
echo "Current commit tag: '$commit_tag'"
if [ -z $commit_tag ]; then
    echo "##teamcity[buildStatus status='FAILURE' text='No commit tag.']"
fi
    echo "##teamcity[setParameter name='COMMIT_TAG' value='$commit_tag']"
```

#### 2. Build docker images
```
bbb8c2e28d7d/applications:%COMMIT_TAG%
```

#### 3. Send image DockerHub
```
bbb8c2e28d7d/applications:%COMMIT_TAG%
```

#### 4. Get Helm repository
```
mkdir %HELM_REPO_FOLDER_NAME%;
cd %HELM_REPO_FOLDER_NAME%;
git clone https://Firewal7:%GITHUB_PERSONAL_TOKEN%@github.com/Firewal7/%FOLDER-GIT%.git;
cd %FOLDER-GIT%
```

#### 5. Сhange file Chart
```
cd %HELM_REPO_FOLDER_NAME%/%FOLDER-GIT%;

# Update chart version.
cd %APP_NAME%;
cat Chart.yaml | sed -e "s/version:.*/version: %COMMIT_TAG%/" > Chart.tmp.yaml
mv Chart.tmp.yaml Chart.yaml

cat Chart.yaml | sed -e "s/appVersion:.*/appVersion: \"%COMMIT_TAG%\"/" > Chart.tmp.yaml
mv Chart.tmp.yaml Chart.yaml

# Update image tag.
cat values.yaml | sed -e "s/tag:.*/tag: \"%COMMIT_TAG%\"/" > values.tmp.yaml
mv values.tmp.yaml values.yaml

cd ..;

# Create Helm-archive.
helm package --version %COMMIT_TAG% -d charts %APP_NAME%;

# Update Helm-index file.
helm repo index charts;

# Update repository.
git add .;
git config --global user.email "%USER_EMAIL%"
git config --global user.name "%USER_NAME%"
git commit -m "Build #%build.number%"
git push origin -f;

# Update previous commit tag.
echo "##teamcity[setParameter name='PREV_COMMIT_TAG' value='$commit_tag']"
```

#### 6. ssh master
```
cd /home/ubuntu/diplom-helm
sudo git pull --rebase
sudo helm upgrade applications /home/ubuntu/diplom-helm/applications  --set container.tag=%COMMIT_TAG%
```
