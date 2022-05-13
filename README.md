# README: notebook

## TODO
### Application development
1. Environment management and service files
   - [ ] `package_scripts`
     - [ ] `docker`
       - [x] `00_docker_build_local.sh` — (re)build container locally.
       - [x] `01_docker_run_local.sh` — run container locally.
       - [ ] `02_docker_compose_run_local.sh` — run `docker-compose.yaml` locally.
       - [ ] `03_docker_run_postgres.sh` — run `PostgreSQL` DB locally in a container.
     - [x] `envs`
       - [x] `00_proj_init_run_once.sh`
       - [x] `01_install_app_dependencies.sh`
       - [x] `02_install_lint_test_dependencies.sh`
       - [x] `03_install_type_test_dependencies.sh`
       - [x] `04_install_unit_test_dependencies.sh`
       - [x] `05_install_docs_dependencies.sh`
       - [x] `06_install_dev_dependencies.sh`
           - [x] `build_run_docs.sh`
           - [x] `docker_postgres_init.sql`
           - [ ] `send_asynchronous_http_requests.sh`
           - [ ] `alembic_stamp.sh`
     - [x] `requirements`
       - [x] `compiled`
         - [x] `01_app_requirements.txt`
         - [x] `02_lint_test_requirements.txt`
         - [x] `03_type_test_requirements.txt`
         - [x] `04_unit_test_requirements.txt`
         - [x] `05_docs_requirements.txt`
         - [x] `06_dev_requirements.txt`
       - [x] `in`
         - [x] `00_proj_init.in`
         - [x] `01_app.in`
         - [x] `02_lint_test.in`
         - [x] `03_type_test.in`
         - [x] `04_unit_test.in`
         - [x] `05_docs.in`
         - [x] `06_dev.in`
   - [ ] `docs`
     - [ ] `unit_tests`
       - [ ] `unit_test_example_01.md` — Develop an example page with auto-documentation of a module with unit tests.
     - [ ] `features`
       - [ ] `feature_example_01.md` — Develop an example of a page with auto-documentation of a module with business
         logic.
     - [x] `index.md`
   - [x] `.dockerignore`
   - [x] `.editorconfig`
   - [x] `.env`
   - [x] `.gitattributes`
   - [x] `.gitignore`
   - [ ] `.gitlab-ci.yml`
   - [x] `.pre-commit-config.yaml`
   - [ ] `alembic.ini`
   - [ ] `alembic_generate_and_stamp_version_table.py`
   - [x] `Dockerfile`
   - [x] `entrypoint.sh`
   - [x] `MANIFEST.in`
   - [x] `mkdocs.yml`
   - [x] `pyproject.toml`
   - [x] `pytest.ini`
   - [ ] `README.md`
   - [x] `requirements.txt`
   - [x] `setup.cfg`
   - [x] `.coverage`
   - [ ] `coverage.xml`
   - [x] `report.xml`
   - [ ] `docker-compose.yml`
   - [ ] `prometheus.yml`
   - [ ] `Jenkinsfile`
   - [ ] `jenkins_properties.groovy`
2. Python application:
   1. Batch version
      - [ ] `app.py`
   2. Online version (`FastAPI`)
      - [ ] `app.py`
      - [ ] `task_processing.py`
      - [ ] `dependencies.py`
      - [ ] `routers`
      - [ ] `schemas`
3. Logging with `ELK`:
   - [ ] Learn about ELK infrastructure.
   - [ ] Develop `custom_logger.py` (`Fluent Bit`, plain text vs `structlog`).
4. Exception monitoring with `Sentry` and/or `Elastic APM`:
   - [ ] Learn about the Sentry infrastructure in different environments. Provide network connectivity.
   - [ ] Develop `sentry_agent.py` and/or `elastic_apm_agent.py`.
   - [ ] Register as middleware in the application.
6. ASGI server:
   - [ ] Develop module `server.py`.
   - [ ] In case of high RPS values. Learn how to configure `Uvicorn` in conjunction with `Gunicorn`.
7. Working with the database:
   - [ ] Develop module `db.py`: metadata, database table schemas, etc.
   - [ ] Develop module `db_privileges.py`.
   - [ ] Develop pydantic data schemas for CRUD operations.
   - [ ] Develop modules with asynchronous CRUD operations for database tables.
   - [ ] Development of a module for creating an instance of the `CRUD` class.
8. REST API client:
   - [ ] Develop class `RESTSession`.
   - [ ] Develop class `RESTHelpers`.
   - [ ] Develop class  `APIError`.
   - [ ] Develop a typical module for asynchronous method invocation of a third-party REST API.
   - [ ] Develop a typical module for asynchronously sending a callback.
9. Testing with `pytest`:
   - [ ] Develop a typical `tests` directory hierarchy.
   - [ ] Develop `conftest.py`.
   - [ ] Develop sample method, class and module with application unit tests.
10. Migrations with `alembic`:
     - [ ] Develop `alembic.ini`.
     - [ ] Develop `env.py`.
     - [ ] Develop `alembic_generate_and_stamp_version_table.py`.
     - [ ] Develop an example schema migration.
     - [ ] Develop an example of data migration.
     - [ ] Develop an example stairway test for migrations.

### `README.md`
1. Typical feature planning artifacts:
   - [ ] Feature testing plan.
   - [ ] Feature development plan. Assessment of possible risks and methods of their management.
2. Code development requirements:
   - [ ] REST API design.
   - [ ] Design of modules, classes, methods.
   - [ ] Object naming.
   - [ ] Type annotation and static type analysis.
   - [ ] Working with the Database from the application.
   - [ ] How to design, test, and apply migrations.
   - [ ] Code formatting check.
   - [ ] Application parameterization. Working with secrets.
   - [ ] Application logging.
   - [ ] Application testing.
   - [ ] Application documentation: `Documentation as Code`, `Swagger`. Thoughtful and helpful comments.
   - [ ] When is it appropriate to refactor code, and when not.
3. Organization of team work:
   - [ ] Rules for working with issues in Jira.
   - [ ] Git branch rules.
   - [ ] Git commit rules: atomic commits, commit comments, etc.
   - [ ] Code review process. Process of delivering code to the `staging` environment.
4. Useful links:
   - [ ] Links to internal project resources in different environments.
   - [ ] Links to external resources that may be useful for solving the problems of the project.
5. IDE settings to be done.
   - [ ] Installing the Python interpreter and project dependencies.
   - [ ] Connecting to databases.
   - [ ] Access to the code repository.
   - [ ] Getting the `.env` file.
   - [ ] Connecting a task management plugin to Jira.

### Teamwork tools and CI/CD
 1. Development process:
    - [ ] `Jira` Kanban board columns should follow the development process.
    - [ ] Creating fields for artifacts in tasks. Workflow automation.
 2. Continuous Integration: `GitLab` or `Jenkins`:
    - [ ] `.gitlab-ci.yaml` or `Jenkinsfile` (Declarative Pipeline).
    - [ ] Customization of project settings in the CI system.
 3. Continuous Deployment:
    - [ ] Learn CD infrastructure and integration methods.
    - [ ] Set up code delivery to `staging` and `production` environments.

## Some useful commands

To build the package:
1. Perform a commit.
2. Run this command in the IDE terminal:
```bash
python -m build
```

To start the local `MKDocs` development server, run this command in the IDE terminal:
```bash
mkdocs serve
```
After starting the server, documentation is usually available at the following address: [http://127.0.0.1:8000/](
http://127.0.0.1:8000/)

Error message suppression:
1. To suppress `mypy` errors: `# type: ignore[<error-id>]`.
2. To suppress `bandit` reports: `# nosec <report-id>`.
3. To suppress `flake8` errors: `# noqa: <error-id>`.

To run `pre-commit` checks manually: `pre-commit run --all-files`
