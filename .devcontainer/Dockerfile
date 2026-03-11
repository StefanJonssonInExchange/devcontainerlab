FROM mcr.microsoft.com/dotnet/sdk:10.0

RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    openssh-client \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Add GitHub to known hosts (avoid SSH prompt on first clone)
RUN mkdir -p /root/.ssh && ssh-keyscan github.com >> /root/.ssh/known_hosts

# Install OpenCode
RUN curl -fsSL https://opencode.ai/install | bash

# Add opencode to PATH (install script typically puts it in ~/.local/bin)
ENV PATH="$PATH:/root/.local/bin"
