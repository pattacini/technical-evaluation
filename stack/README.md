This is the Docker description of the Stack of components required
to run our technical evaluation on a cloud IDE.

### Instructions
1. Clone this repository locally.
1. Create a token within GitHub with `repo` scope.
1. Assign the token to the `GITHUB_TOKEN` argument within the Dockerfile.
1. Assign tag=["codenvy"|"gitpod"], hence `cd ${tag}`.
1. Build the docker image: `docker build --tag pattacini/technical-evaluation-stack:${tag} - < Dockerfile`. Working locally we don't expose the token publicly.
1. Check the status of the newly created image: `docker images`. 
1. Push the image to DockerHub: `docker push pattacini/technical-evaluation-stack:${tag}`.
1. Go to DockerHub and add/check information.
1. Delete the GitHub token.
1. Optionally, remove the local docker image: `docker rmi --force pattacini/technical-evaluation-stack:${tag}`.
