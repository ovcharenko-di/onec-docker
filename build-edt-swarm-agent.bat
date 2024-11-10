@echo off

docker login -u %DOCKER_LOGIN% -p %DOCKER_PASSWORD% %DOCKER_REGISTRY_URL%

if %ERRORLEVEL% neq 0 goto end

if %DOCKER_SYSTEM_PRUNE%=="true" docker system prune -af

if %ERRORLEVEL% neq 0 goto end

for /f "delims=." %%a in ("%EDT_VERSION%") do set EDT_MAJOR_VERSION=%aa
if %EDT_MAJOR_VERSION% GEQ "2024" (
  set BASE_IMAGE="azul/zulu-openjdk"
  set BASE_TAG="17.0.13-jdk"
) else (
  set BASE_IMAGE="eclipse-temurin"
  set BASE_TAG="11"
)

if %ERRORLEVEL% neq 0 goto end

if %NO_CACHE%=="true" (SET last_arg="--no-cache .") else (SET last_arg=".")

set edt_version=%EDT_VERSION%
set edt_escaped=%edt_version: =_%

docker build ^
	--pull ^
	--build-arg DOCKER_REGISTRY_URL=library ^
    --build-arg BASE_IMAGE=ubuntu ^
    --build-arg BASE_TAG=20.04 ^
    --build-arg ONESCRIPT_PACKAGES="yard" ^
    -t %DOCKER_REGISTRY_URL%/oscript-downloader:latest ^
	-f oscript/Dockerfile ^
    %last_arg%

docker build ^
	--build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
	--build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
    --build-arg EDT_VERSION=%EDT_VERSION% ^
    --build-arg BASE_IMAGE=%BASE_IMAGE% ^
    --build-arg BASE_TAG=%BASE_TAG% ^
    --build-arg DOCKER_REGISTRY_URL=%DOCKER_REGISTRY_URL% ^
    --build-arg DOWNLOADER_IMAGE=oscript-downloader ^
    --build-arg DOWNLOADER_TAG=latest ^
	-t %DOCKER_REGISTRY_URL%/onec-client:%edt_escaped% ^
	-f edt/Dockerfile ^
	%last_arg%

if %ERRORLEVEL% neq 0 goto end

docker build ^
    --build-arg DOCKER_REGISTRY_URL=%DOCKER_REGISTRY_URL% ^
    --build-arg BASE_IMAGE=edt ^
    --build-arg BASE_TAG=%edt_escaped% ^
    -t %DOCKER_REGISTRY_URL%/base-jenkins-agent:%edt_escaped% ^
    -f swarm-jenkins-agent/Dockerfile ^
    %last_arg%

if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_REGISTRY_URL%/base-jenkins-agent:%edt_escaped%

if %ERRORLEVEL% neq 0 goto end

:end
echo End of program.
