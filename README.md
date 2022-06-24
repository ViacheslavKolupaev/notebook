# README: notebook
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
