# nomad-deploy-action
This repo will take a Nomad job, replace variables and deploy the job file.

## Environment Variables

| Variable              | Details                                                 | Example                                    |
|-----------------------|---------------------------------------------------------|--------------------------------------------|
| NOMAD_JOB             | The Nomad job file path.                                | `nomad-jobs/dev/app.nomad`                 |
| NOMAD_ADDR            | The remote Nomad url.                                   | `https://example.com`                      |
| NOMAD_PORT            | The remote Nomad port.                                  | `4646`                                     |
