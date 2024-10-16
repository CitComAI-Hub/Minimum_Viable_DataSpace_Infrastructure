# FIWARE Data Space Connector

Latest version (2.x) of the [FIWARE Data Space Connector](https://github.com/FIWARE/data-space-connector).

## Components

- DS Trust Anchor (Operator)
- DS Connector (Provider / Consumer)

**Helm chart repo:** `https://fiware.github.io/data-space-connector/`

## Trust Anchor (Operator)

| Module       | Version |
| ------------ | ------- |
| trust-anchor | 0.2.0   |

**Helm code:** `https://github.com/FIWARE/data-space-connector/tree/main/charts/trust-anchor`

![arch_trust_anchor](./images/trust_anchor_arch.png)

## Connector (Provider / Consumer)

| Module               | Version |
| -------------------- | ------- |
| data-space-connector | 7.3.3   |

**Helm code:** `https://github.com/FIWARE/data-space-connector/tree/main/charts/data-space-connector`

### Provider

![arch_provider](./images/provider_arch.png)

### Consumer

![arch_consumer](./images/consumer_arch.png)