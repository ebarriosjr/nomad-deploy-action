# nomad-deploy-action
This repo will take a Nomad job, replace variables and deploy the job file.

## Environment Variables

| Variable   | Details                  | Default            | Example                    |
|-------------|--------------------------|--------------------|----------------------------|
| NOMAD_JOB   | The Nomad job file path. |                    | `nomad-jobs/dev/app.nomad` |
| NOMAD_ADDR  | The remote Nomad url.    | `http://127.0.0.1` | `https://example.com`      |
| NOMAD_PORT  | The remote Nomad port.   | `4646`             | `4646`                     |
| NOMAD_VAR_* | Variables needed to template the file. Format NOMAD_VAR_variable_name = value.| | |

# WARNINGS

Nomad job run command works as follow:

```
On successful job submission and scheduling, exit code 0 will be returned. If there are job placement issues encountered (unsatisfiable constraints, resource exhaustion, etc), then the exit code will be 2. Any other errors, including deployment failures, client connection issues, or internal errors, are indicated by exit code 1.
```

That is why a case switch was added on the bash script that generates the following exits:

|Exit Code|Label| Message                            |Remarks|
|:-------:|:-----:|------------------------------------|-------|
|    0    | INFO  | SUCCESSFULL deploy job       ||
|    1    | ERROR | FAILED to deploy job        ||
|    2    | WARN  | RESOURCE EXHAUSTION detected ||
|    3    | ERROR | Job rolled back after failed| When a job has an automatic rollback it will exit with exit code 0 if the rollback was successfull. So the action would not be marked as failed. With this logic it will.|
