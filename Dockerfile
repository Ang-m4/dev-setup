# Test environment for validating setup scripts on a clean Ubuntu system.
# Simulates a fresh machine with a non-root user and sudo access.

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Create a non-root test user
RUN useradd -m -s /bin/bash testuser \
    && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY . /home/testuser/custom-instance
RUN chown -R testuser:testuser /home/testuser/custom-instance

USER testuser
WORKDIR /home/testuser/custom-instance

CMD ["bash"]
