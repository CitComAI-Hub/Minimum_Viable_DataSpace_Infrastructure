# FIWARE Data Space (FDS) Ecosystem

The FIWARE Data Space (FDS) is a set of components that allow the creation of a data space. The data space is a secure and trusted environment where data providers and consumers can exchange data in a secure and trusted way.

In the minimal version of the data space, we have the following components:

- **FIWARE Data Space Trust Anchor**: The trust anchor is the entity that manages the issuers and credentials for all participants in the data space.

- **FIWARE Data Space Connector (Provider)**: The connector is the entity that provides data from the data space. In this deployment, we use the latest version (2.x) of the [FIWARE Data Space Connector](https://github.com/FIWARE/data-space-connector).

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
        <a href="#trust-anchor-operator">Trust Anchor (Operator)</a>
    </li>
    <li>
        <a href="#fds-connector">FDS Connector</a>
        <ul>
            <li><a href="#consumer">Consumer</a></li>
            <li><a href="#providerconsumer">Provider/Consumer</a></li>
        </ul>
    </li>
  </ol>
</details>

## Trust Anchor (Operator)

FIWARE has developed a Trust Anchor Operator as a Helm chart, that manages issuers and credentials for all participants in the data space. 

| Module       | Version | Repository | Chart code |
| ------------ | ------- | ---------- | ----------- |
| trust-anchor | 0.2.0   | `https://fiware.github.io/data-space-connector/` | [GitHub](https://github.com/FIWARE/data-space-connector/tree/main/charts/trust-anchor) |

![arch_trust_anchor](./images/trust_anchor_arch.svg)

## FDS Connector

The FIWARE Data Space (FDS) Connector is a Helm chart that allows the deployment of a connector in the data space. Depending on the configuration, the connector can be: **provider/consumer** or **consumer**.

| Module               | Version | Repository | Chart code |
| -------------------- | ------- | ---------- | ---------- |
| data-space-connector | 7.29.0  | `https://fiware.github.io/data-space-connector/` | [GitHub](https://github.com/FIWARE/data-space-connector/tree/main/charts/data-space-connector) |

|  Component | Version | Repository |
| ---------- | ------- | ---------- |
| DSS Validation Service | 0.0.14 | `https://fiware.github.io/helm-charts` |

### Consumer

The consumer connector is an entity that only consumes data from the data space.

More [info](https://github.com/FIWARE/data-space-connector/blob/main/doc/deployment-integration/local-deployment/LOCAL.MD#the-data-consumer).

The following diagram shows the main blocks of the architecture of the consumer connector:

![arch_consumer](./images/consumer_arch.svg)

|  Component | Version | Repository |
| ---------- | ------- | ---------- |
| Keycloak | 24.0.1 | `https://charts.bitnami.com/bitnami` |
| Postgresql | 13.1.5 | `oci://registry-1.docker.io/bitnamicharts` |

### Provider

The provider connector is an entity that provides data from the data space. This component is composed of four main blocks:

1. **Data Services**: In this example we use Scorpio Broker (NGSI-LD Context Broker).
2. **Authentication**: VCVerifier, CredentialsConfigService, TrustedIssuersList.
3. **Authorization**: Gateway (APISIX), Open Policy Agent, ODRL-PAP.
4. **Value Creation**: TMForum API, Contract Management.
5. **IDSA-Data Space Protocol**: TPP, Rainbow.

More [info](https://github.com/FIWARE/data-space-connector/blob/main/doc/deployment-integration/local-deployment/LOCAL.MD#the-data-provider).

The following diagram shows the main blocks of the architecture of the provider connector:

![arch_provider](./images/provider_arch.svg)

|  Component | Version | Repository |
| ---------- | ------- | ---------- |
| APISIX | 3.5.1 | `oci://registry-1.docker.io/bitnamicharts` |
| ODRL-PAP | 0.2.2 | `https://fiware.github.io/helm-charts` |
| VCverifier | 2.11.3  | `https://fiware.github.io/helm-charts` |
| Postgresql | 13.1.5 | `oci://registry-1.docker.io/bitnamicharts` |
| MySQL | 9.4.4 | `https://charts.bitnami.com/bitnami` |
| Trusted Issuers List | 0.7.0 | `https://fiware.github.io/helm-charts` |
| Credentials Config Service | 0.1.6 | `https://fiware.github.io/helm-charts` |
| Contract Management | 1.0.2 | `https://fiware.github.io/helm-charts` |
| TM Forum API | 0.10.0 | `https://fiware.github.io/helm-charts` |
| Scorpio Broker | 0.4.7 | `https://fiware.github.io/helm-charts` |
