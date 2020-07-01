# initializing

## python virtual env

This venv should reside outside of the git repository AND outside the vscode workspace directory:
```bash
../python3.8 -m venv ../../pyrt-vi
..source ../../pyrt-vi/bin/activate
```

## git branch

work is done on a git feature branch e.g.

```bash
git branch dbt_qstat_var1
git checkout dbt_qstat_var1
```

## setup der python virtual env and init the dbt project structure

```bash
pip install -r requirements.txt
dbt init dbt_qstat
```

