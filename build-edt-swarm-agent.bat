@echo off

.\build-edt.bat

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
