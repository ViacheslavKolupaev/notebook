# README: notebook

## TODO
### Application
1. Python modules

2. Logging with `ELK`:
   - [ ] Learn about ELK infrastructure.
   - [ ] Develop `custom_logger.py` (`Fluent Bit`, plain text vs `structlog`).
3. Exception monitoring with `Sentry` or `Elastic APM`:
   - [ ] Learn about the Sentry infrastructure in different environments. Provide network connectivity.
   - [ ] Develop `sentry_agent.py` or `elastic_apm_agent.py`.
   - [ ] Register as middleware in the application.
4. Shell scripts
   - [ ] Script for sending asynchronous HTTP requests to pplication endpoints.
   - [ ] Script to execute `alembic_generate_and_stamp_version_table.py`
5. ASGI server:
   - [ ] Develop module `server.py`.
   - [ ] In case of high RPS values. Learn how to configure `Uvicorn` in conjunction with `Gunicorn`.
6. Working with the database:
   - [ ] Develop module `db.py`: metadata, database table schemas, etc.
   - [ ] Develop module `db_privileges.py`.
   - [ ] Develop pydantic data schemas for CRUD operations.
   - [ ] Develop modules with asynchronous CRUD operations for database tables.
   - [ ] Development of a module for creating an instance of the `CRUD` class.
7. REST API client:
   - [ ] Develop class `RESTSession`.
   - [ ] Develop class `RESTHelpers`.
   - [ ] Разработать класс `APIError`.
   - [ ] Develop a typical module for asynchronous method invocation of a third-party REST API.
   - [ ] Develop a typical module for asynchronously sending a callback.
8. Testing with `pytest`:
   - [ ] Develop a typical `tests` directory hierarchy.
   - [ ] Develop `conftest.py`.
   - [ ] Develop sample method, class and module with application unit tests.
9. Migrations with `alembic`:
    - [ ] Develop `alembic.ini`.
    - [ ] Develop `env.py`.
    - [ ] Develop `alembic_generate_and_stamp_version_table.py`.
    - [ ] Develop an example schema migration.
    - [ ] Develop an example of data migration.
    - [ ] Develop an example stairway test for migrations.
10. Documentation
    1. `README.md`
      - Typical feature planning artifacts:
        - [ ] Feature testing plan.
        - [ ] Feature development plan. Assessment of possible risks and methods of their management.
      - Code development requirements:
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
      - Organization of team work:
        - [ ] Rules for working with issues in Jira.
        - [ ] Git branch rules.
        - [ ] Git commit rules: atomic commits, commit comments, etc.
        - [ ] Code review process. Process of delivering code to the `staging` environment.
      - Useful links:
        - [ ] Links to internal project resources in different environments.
        - [ ] Links to external resources that may be useful for solving the problems of the project.
      - IDE settings to be done.
        - [ ] Installing the Python interpreter and project dependencies.
        - [ ] Connecting to databases.
        - [ ] Access to the code repository.
        - [ ] Getting the `.env` file.
        - [ ] Connecting a task management plugin to Jira.
    2. Project autodocumentation
      - [ ] Develop `mkdocs.yaml`
      - [ ] Develop an example of a page with auto-documentation of a module with business logic.
      - [ ] Develop an example page with auto-documentation of a module with unit tests.

11. Deployment tools
     1. `Jira`:
        - [ ] Kanban board columns should follow the development process.
        - [ ] Creating fields for artifacts in tasks. Workflow automation.
     2. Integration with CI
        - [ ]`.gitlab-ci.yaml` or `Jenkinsfile (Declarative Pipeline)`
        - [ ] Customization of CI settings.
     3. `Docker`
         - Manifests
           - [ ] `docker-compose.yaml`
         - Shell scripts
             - [ ] (re)build container locally;
             - [ ] run container locally;
             - [ ] run `docker-compose.yaml` locally;
             - [ ] run `PostgreSQL` DB locally in a container.

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
