FROM ubuntu:xenial-20200916

#ARG pip_installer="https://bootstrap.pypa.io/get-pip.py"
#ARG awscli_version="2.0.47"

# create local bin directory
#RUN mkdir -p /root/.local/bin 
#ENV PATH $PATH:/root/.local/bin

# install utils
RUN apt-get update && apt-get install -y curl less vim unzip openssh-client wget

# install aws-cli
#RUN pip install --user --upgrade awscli==${awscli_version}
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

RUN bash -c 'echo complete -C '/usr/bin/aws_completer' aws  >> $HOME/.bashrc'
ENV PS1="awscliv2> "

# install sam
#RUN pip install --user --upgrade aws-sam-cli

# install iam-authenticator
RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/aws-iam-authenticator && chmod +x ./aws-iam-authenticator && mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin && echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

# install kubectl.
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

# install eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && mv /tmp/eksctl /usr/local/bin

# git install
RUN apt-get install -y git

# terraform
RUN wget https://releases.hashicorp.com/terraform/0.14.3/terraform_0.14.3_linux_arm64.zip && unzip terraform_0.14.3_linux_arm64.zip && mv terraform /usr/local/bin && rm terraform_0.14.3_linux_arm64.zip

WORKDIR /root