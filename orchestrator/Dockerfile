FROM openjdk:8-slim-buster@sha256:909df91324a3c147922036a82b69eb9b73ee902b80e382eadcf35a534158c6d4

ENV TZ="America/Denver"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  git \
  wget \
  curl \
  gnupg \
  rsync \
  sudo \
  unzip \
  vim \
  openssh-client \
  openssh-server \
  python3 \
  python3-pip \
  python3-setuptools \
  && pip3 install --upgrade pip \
  && pip3 install wheel setuptools ansible==2.10 \
  && ln -sf /usr/bin/python3 /usr/bin/python \
  && apt-get -y autoremove \
  && apt-get clean autoclean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Install Gradle
ENV GRADLE_VERSION=6.6.1
ARG GRADLE_DOWNLOAD_SHA256=7873ed5287f47ca03549ab8dcb6dc877ac7f0e3d7b1eb12685161d10080910ac

RUN set -o errexit -o nounset \
  && echo "Downloading Gradle" \
  && wget --no-verbose --output-document=/tmp/gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
  \
  && echo "Checking Gradle download hash" \
  && echo "${GRADLE_DOWNLOAD_SHA256} /tmp/gradle.zip" | sha256sum --check - \
  \
  && echo "Installing Gradle" \
  && unzip /tmp/gradle.zip -d /opt/ \
  && rm /tmp/gradle.zip \
  && mv /opt/gradle* /opt/gradle \
  && ln --symbolic /opt/gradle/bin/gradle /usr/bin/gradle \
  \
  && echo "Testing Gradle installation" \
  && gradle --version


# Install Hashicorp Vault
ENV VAULT_VERSION=1.8.1
ARG VAULT_DOWNLOAD_SHA256=bb411f2bbad79c2e4f0640f1d3d5ef50e2bda7d4f40875a56917c95ff783c2db

RUN set -o errexit -o nounset \
  && echo "Downloading Hashicorp Vault" \
  && wget --no-verbose --output-document=/tmp/vault.zip "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" \
  \
  && echo "Checking Vault download hash" \
  && echo "${VAULT_DOWNLOAD_SHA256} /tmp/vault.zip" | sha256sum --check - \
  \
  && echo "Installing Vault" \
  && unzip /tmp/vault.zip -d /opt/ \
  && rm /tmp/vault.zip \
  && ln --symbolic /opt/vault /usr/bin/vault \
  \
  && echo "Testing Vault installation" \
  && vault --version


RUN set -eux; \
	groupadd --gid 999 --system app-user; \
  useradd --uid 999 --system --shell /bin/bash --create-home --gid app-user app-user;

USER app-user
WORKDIR /home/app-user
