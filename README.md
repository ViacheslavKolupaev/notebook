notebook
=======

![GitLab License](https://img.shields.io/gitlab/license/vkolupaev/notebook?color=informational)
![GitLab tag (latest by SemVer)](https://img.shields.io/gitlab/v/tag/vkolupaev/notebook)
![Python](https://img.shields.io/static/v1?label=Python&message=3.10&color=informational&logo=python&logoColor=white)


## Some useful commands

---

Error message suppression:
1. To suppress `mypy` errors: `# type: ignore[<error-id>]`.
2. To suppress `bandit` reports: `# nosec <report-id>`.
3. To suppress `flake8` errors: `# noqa: <error-id>`.

---

To run `pre-commit` checks manually: `pre-commit run --all-files`

---

To build the Python package:
1. Perform a commit.
2. Run this command in the IDE terminal:
```bash
python -m build
```

---

To start the local `MKDocs` development server, run this command in the IDE terminal:
```bash
mkdocs serve
```
After starting the server, documentation is usually available at the following address: [http://127.0.0.1:8000/](
http://127.0.0.1:8000/)

---

## CI/CD notes
1. Service directories of the CI server should be excluded from `mypy` and `flake8` checks.

---

Copyright 2022 [Viacheslav Kolupaev](
https://vkolupaev.com/?utm_source=readme&utm_medium=link&utm_campaign=notebook
).

[![website](
https://img.shields.io/static/v1?label=website&message=vkolupaev.com&color=blueviolet&style=for-the-badge&
)](https://vkolupaev.com/?utm_source=readme&utm_medium=badge&utm_campaign=notebook)

[![LinkedIn](
https://img.shields.io/static/v1?label=LinkedIn&message=vkolupaev&color=informational&style=flat&logo=linkedin
)](https://www.linkedin.com/in/vkolupaev/)
[![Telegram](
https://img.shields.io/static/v1?label=Telegram&message=@vkolupaev&color=informational&style=flat&logo=telegram
)](https://t.me/vkolupaev/)
