# Fiware Data Space Components

## Trust Anchor (Operator)

FIWARE has developed a Trust Anchor Operator as a Helm chart, that manages issuers and credentials for all participants in the data space. 

| Module       | Version | Repository | Chart code |
| ------------ | ------- | ---------- | ----------- |
| trust-anchor | 0.2.0   | `https://fiware.github.io/data-space-connector/` | [GitHub](https://github.com/FIWARE/data-space-connector/tree/main/charts/trust-anchor) |

![arch_trust_anchor](./img/trust_anchor_arch.svg)

### Consumer

The consumer connector is an entity that only consumes data from the data space. More [info](https://github.com/FIWARE/data-space-connector/blob/main/doc/deployment-integration/local-deployment/LOCAL.MD#the-data-consumer).

The following diagram shows the main blocks of the architecture of the consumer connector:

![arch_consumer](./img/consumer_arch.svg)

|  Component | Version | Repository |
| ---------- | ------- | ---------- |
| Keycloak | 24.0.1 | `https://charts.bitnami.com/bitnami` |
| Postgresql | 13.1.5 | `oci://registry-1.docker.io/bitnamicharts` |

> [!WARNING]
> By default the consumer DID issuer is not registered in the trust anchor. You can register it by running the service `registration` (only for test environments).

