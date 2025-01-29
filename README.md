# InterSystems FHIR Facade Container (With FHIR Server Enabled)

1. Clone or download this repostory to your local machine.
2. (optional) Edit the webserver port in `.env`.
3. (optional, default: SYS) Change IRIS password in `./src-iris/irispw.txt`.
4. Build the container images: `docker compose build --progress=plain`.
5. Create and run containers: `docker-compose up -d`
6. The IRIS management portal: http://localhost:8082/csp/sys/%25CSP.Portal.Home.zen
7. The FHIR EndPoint is /fhirserver/fhir/r4/. All the patients in the fhirdata folder was loaded
8. Swagger API: http://localhost:8082/swagger-ui/index.html?url=http://localhost:8082/fhirfacade/_spec#

Additonal commands

- Stop Demo: `docker-compose stop`
- Start Demo: `docker-compose start`
- Delete all docker resources of the demo: `docker-compose down`