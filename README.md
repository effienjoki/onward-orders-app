# onward-orders-app

# Onward Logistics order app

A single full stack Java application: it serves the order page and processes orders in one container. It runs on Amazon ECS Fargate and is released automatically when changes are merged to `main`.

Infrastructure and architecture diagram: [onward-orders-infrastructure](https://github.com/effienjoki/onward-orders-infrastructure)

## What is in this repo

| Path | Purpose |
| --- | --- |
| `src/OrderApp.java` | The app. Uses only the Java standard library. Shows the owner, lab name, version, task ID and Availability Zone |
| `Dockerfile` | Multi stage build: compile with a JDK, run on a small JRE image as a non root user |
| `.github/workflows/build-and-push.yml` | Builds the image and pushes it to ECR using OIDC |
| `deploy/taskdef.json` | How each new version runs on ECS (CPU, memory, port, logs). `<IMAGE1_NAME>` is filled in by CodePipeline |
| `deploy/appspec.yaml` | Tells CodeDeploy which container and port receive traffic. `<TASK_DEFINITION>` is filled in by CodePipeline |

## How to release a change

1. Make the change on a branch and open a pull request.
2. Merge to `main`.

That is all. GitHub Actions builds and pushes the image, and the delivery pipeline releases it with a blue/green canary. Watch progress in the **Actions** tab, then in AWS CodePipeline and CodeDeploy.

## How GitHub reaches AWS without keys

The workflow requests an OIDC token from GitHub and exchanges it with AWS STS for temporary credentials. The role it assumes:

- trusts only this repository's `main` branch (matched on immutable owner and repository IDs)
- can only push images to the `onward-dev-orders` ECR repository

The role ARN is stored as the repository **variable** `AWS_ROLE_ARN`. It is not a secret: it is useless without a valid token from this repository. There are no AWS secrets in this repository.

## Run it locally

    java src/OrderApp.java

Then open http://localhost:8080. Health check: http://localhost:8080/health

## Build the image locally

    docker build -t onward-orders:local .
    docker run -p 8080:8080 onward-orders:local