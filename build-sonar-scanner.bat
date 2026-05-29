@echo off

docker login -u %DOCKER_LOGIN% -p %DOCKER_PASSWORD% %DOCKER_REGISTRY_URL%

if %ERRORLEVEL% neq 0 goto end

if %DOCKER_SYSTEM_PRUNE%=="true" docker system prune -af

if %ERRORLEVEL% neq 0 goto end

if %NO_CACHE%=="true" (SET last_arg="--no-cache .") else (SET last_arg=".")

rem SonarScanner CLI 8.x требует Java 21+, поэтому слой jdk собираем с JDK 21
if "%SONAR_JDK_VERSION%"=="" set SONAR_JDK_VERSION=21

docker build ^
	--pull ^
	--build-arg DOCKER_REGISTRY_URL=library ^
	--build-arg BASE_IMAGE=ubuntu ^
	--build-arg BASE_TAG=20.04 ^
	--build-arg ONESCRIPT_PACKAGES="yard" ^
	-t %DOCKER_REGISTRY_URL%/oscript-downloader:latest ^
	-f oscript/Dockerfile ^
	%last_arg%

if %ERRORLEVEL% neq 0 goto end

docker build ^
	--build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
	--build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
	--build-arg ONEC_VERSION=%ONEC_VERSION% ^
	--build-arg DOCKER_REGISTRY_URL=%DOCKER_REGISTRY_URL% ^
	--build-arg BASE_IMAGE=oscript-downloader ^
	--build-arg BASE_TAG=latest ^
	-t %DOCKER_REGISTRY_URL%/onec-client:%ONEC_VERSION% ^
	-f client/Dockerfile ^
	%last_arg%

if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_REGISTRY_URL%/onec-client:%ONEC_VERSION%

if %ERRORLEVEL% neq 0 goto end

docker build ^
	--build-arg DOCKER_REGISTRY_URL=%DOCKER_REGISTRY_URL% ^
	--build-arg BASE_IMAGE=onec-client ^
	--build-arg BASE_TAG=%ONEC_VERSION% ^
	--build-arg OPENJDK_VERSION=%SONAR_JDK_VERSION% ^
	-t %DOCKER_REGISTRY_URL%/onec-client-jdk:%ONEC_VERSION% ^
	-f jdk/Dockerfile ^
	%last_arg%

if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_REGISTRY_URL%/onec-client-jdk:%ONEC_VERSION%

if %ERRORLEVEL% neq 0 goto end

docker build ^
	--build-arg DOCKER_REGISTRY_URL=%DOCKER_REGISTRY_URL% ^
	--build-arg BASE_IMAGE=onec-client-jdk ^
	--build-arg BASE_TAG=%ONEC_VERSION% ^
	-t %DOCKER_REGISTRY_URL%/onec-sonar-scanner:%ONEC_VERSION% ^
	-f sonar-scanner/Dockerfile ^
	%last_arg%

if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_REGISTRY_URL%/onec-sonar-scanner:%ONEC_VERSION%

if %ERRORLEVEL% neq 0 goto end

:end
echo End of program.
