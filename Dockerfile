FROM mambaorg/micromamba:git-eb92c8f-amazon2023

# --- ARGUMENTS ---
ARG DUCKDB_VERSION=1.4.3
ARG TARGETARCH

# --- STAGE 1: Base & JDK & GIT & DuckDB CLI ---
USER root
RUN dnf install -y --allowerasing \
        java-21-amazon-corretto-devel \
        git \
        curl \
        unzip \
        ca-certificates && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Install DuckDB CLI
# Adapted from apt-get to use curl (available in this base)
RUN set -eux; \
    arch="${TARGETARCH:-amd64}"; \
    if [ "$arch" = "amd64" ]; then duckdb_zip="duckdb_cli-linux-amd64.zip"; \
    elif [ "$arch" = "arm64" ]; then duckdb_zip="duckdb_cli-linux-aarch64.zip"; \
    else echo "Unsupported TARGETARCH: $arch" >&2; exit 1; fi; \
    curl -L -o /tmp/duckdb.zip "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/${duckdb_zip}"; \
    unzip /tmp/duckdb.zip -d /usr/local/bin; \
    rm -f /tmp/duckdb.zip; \
    chmod +x /usr/local/bin/duckdb

# --- STAGE 2: Setup Genet Library ---
USER $MAMBA_USER
WORKDIR /app

# Install DuckDB 'arrow' extension
# We run this as MAMBA_USER so the extension is saved to the user's config (~/.duckdb), not root's.
RUN duckdb -c "INSTALL arrow FROM community; LOAD arrow;"

# Cache Busting for Genet
ADD https://api.github.com/repos/arup-group/genet/git/refs/heads/main /tmp/genet_version.json
RUN git clone -b main https://github.com/arup-group/genet genet

# Install requirements
RUN micromamba install -y -n base -c conda-forge -c city-modelling-lab \
    python=3.11 "proj>=9.3" pip coin-or-cbc \
    --file ./genet/requirements/base.txt && \
    micromamba clean --all --yes

ARG MAMBA_DOCKERFILE_ACTIVATE=1

RUN pip install --no-deps ./genet

# --- STAGE 3: Setup Client-Bro ---
WORKDIR /app

# Cache Busting for Client-Bro
ADD https://api.github.com/repos/nguyenlamnghia/client-bro/git/refs/tags/scenario_8 /tmp/client_version.json
RUN git clone -b scenario_8 --single-branch --depth 1 https://github.com/nguyenlamnghia/client-bro client-bro

WORKDIR /app/client-bro
RUN pip install .

USER root
RUN mkdir -p logs && chmod 777 logs
USER $MAMBA_USER

# --- STAGE 4: Download jar file ---
WORKDIR /app/client-bro/matsim
ARG VERSION=v2.10.6
ARG ZIP=dist-2.10.6.zip
ARG SHA256=30b2b210dc973e15750336e95d12b27a0077b7432d5fa57fa13075c8ef61ecbf

# download (cache)
RUN curl -L -o ${ZIP} \
    https://github.com/ITS-Simulation/MATSim_Custom/releases/download/${VERSION}/${ZIP}

# verify + unzip
RUN echo "${SHA256}  ${ZIP}" | sha256sum -c - \
 && unzip ${ZIP} \
 && rm ${ZIP}

# --- STAGE 5: Runtime ---
WORKDIR /app/client-bro

ENTRYPOINT ["micromamba", "run", "-n", "base", "client-bro"]
CMD ["localhost", "proccess_number"]
