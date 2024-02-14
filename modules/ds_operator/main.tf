locals {
  mongo_service    = "${var.namespace}-mongodb"
  orionld_service  = "${var.namespace}-orion-ld"
  tpr_service      = "${var.namespace}-trusted-participants-registry"
  keyrock_service  = "${var.namespace}-keyrock"
  pdp_service      = "${var.namespace}-pdp"
  kong_service     = "${var.namespace}-kong"
  mysql_service    = "${var.namespace}-mysql"
  ccs_service      = "${var.namespace}-cred-conf-service"
  til_service      = "${var.namespace}-trusted-issuers-list"
  waltid_service   = "${var.namespace}-waltid"
  verifier_service = "${var.namespace}-verifier"
}

#* DONE
resource "helm_release" "mongodb" {
  chart            = var.mongodb.chart_name
  version          = var.mongodb.version
  repository       = var.mongodb.repository
  name             = local.mongo_service
  namespace        = var.namespace
  create_namespace = true

  set {
    name  = "service.type"
    value = "LoadBalancer" # ClusterIP for internal access only.
  }

  values = [<<EOF
        architecture: standalone
        auth:
            enabled: true
            rootPassword: ${var.mongodb.root_password}
        podSecurityContext:
            enabled: false
        containerSecurityContext:
            enabled: false
        resources:
            limits:
            cpu: 200m
            memory: 512Mi
        persistence:
            enabled: true
            size: 8Gi
        EOF
  ]

}

#* DONE
resource "helm_release" "mysql" {
  chart            = var.mysql.chart_name
  version          = var.mysql.version
  repository       = var.mysql.repository
  name             = local.mysql_service
  namespace        = var.namespace
  create_namespace = true

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    <<EOF
        fullnameOverride: ${local.mysql_service}
        auth:
            rootPassword: ${var.mysql.root_password}
        initdbScripts:
            create.sql: |
                CREATE DATABASE ${var.mysql.til_db};
                CREATE DATABASE ${var.mysql.ccs_db};
        EOF
  ]
}

#TODO: test API
resource "helm_release" "orion_ld" {
  chart      = var.orion_ld.chart_name
  version    = var.orion_ld.version
  repository = var.orion_ld.repository
  name       = local.orionld_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "LoadBalancer" # ClusterIP for internal access only.
  }

  values = [<<EOF
        deployment:
            additionalAnnotations:
                prometheus.io/scrape: 'true'
                prometheus.io/port: '8000'
        
        # Configuration for the orion-ld service
        broker:
            db:
                # The db to use. if running in multiservice mode, its used as a prefix.
                # maximum 10 characters!
                name: orion-oper
                auth: 
                    user: root
                    password: ${var.mongodb.root_password}
                    mech: "SCRAM-SHA-1"
                # Configuration of the mongo-db hosts. if multiple hosts are inserted,
                # its assumed that mongo is running as a replica set
                hosts:
                    - ${local.mongo_service}        
        # Configuration for embedding mongodb into the chart. Do not use this in production.
        mongo:
            enabled: false
        EOF
  ]

  depends_on = [helm_release.mongodb]
}

resource "helm_release" "trusted_participants_registry" {
  chart      = var.trusted_participants_registry.chart_name
  version    = var.trusted_participants_registry.version
  repository = var.trusted_participants_registry.repository
  name       = local.tpr_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    <<EOF
        deployment:
          # image:
          #   tag: 0.6.0
          #   pullPolicy: Always
          additionalLabels:
            participant: onboarding
        # route:
        #   enabled: true
        #   host: tir.dsba.fiware.dev
        #   tls:
        #     insecureEdgeTerminationPolicy: Redirect
        #     termination: edge
        #   certificate:
        #     issuer:
        #       kind: ClusterIssuer
        #       name: letsencrypt-aws-prod

        tir:
          ngsiBroker:
            url: http://${local.orionld_service}:1026/
          contextUrl: "https://registry.${var.ds_domain}/development/api/trusted-shape-registry/v1/shapes/jsonld/trustframework#"
          # satellite:
          #   id: "EU.EORI.FIWARESATELLITE"
          #   key: |
          #     -----BEGIN RSA PRIVATE KEY-----
          #     MIIJKAIBAAKCAgEAvEn4Tip8LAqXMXBl86H2n+TmtVQElw6r9tZUELVrPSgc6EiW
          #     AyeA8x+jCyFW7Da03roMhew9sm4M6qkNfYoHjY+z2WJm8Jc0PwfXkGkaQMI3TReI
          #     dXEKV1Qi0i2vf1sLcVeoU3U7P/Xq97QohotXwntR4IJf8pBAuDsWKtwgM5p3yO08
          #     JiO9taC3T15G8jOOiB20Dq8v3ShV442n98rq+OpPTXxHNxHd1uL6nSC1RdYIxVIm
          #     PBEFUzXEd0QV4mkIB8hHG3z3M5UDiuuxMmgPpidYMNAORRanhhc7urwj1/0nx1Mx
          #     79IwIMooNkDnTMuQA9RA7NRdQzdEEQkqOEyCK8/e7QNDrvhealbvSamI3kvfwKG3
          #     bPTv7UYwMoOralRNE4fSssscPQid5td9eiTabuACCCQR2hBPxKPRWfyWf16xZ9Es
          #     HSaICrRl/gArjLbCLLs0H4VeKnB2SlgRvm7VhXpKiUBJNANbjFfCoaMoNPIaKNUP
          #     qdbj4sdhNF+lAGA4RoHQ8RsZwxGYAS+MkII6Fsw3v6wDwY75XIXTx/UFIFLMZVWv
          #     MojbssfKWW+NMikQki+COTli5N+/7GKsbJY6aG4SZd/dGBN+S34ZqimUoVTJzQ3s
          #     UEPdqPiw+zDy4Uq1ai9KPwwyJc7jncp5Z8qeawMw4ga//gcA6mF4RL+XxmUCAwEA
          #     AQKCAgAty7/9IxA4lgrYF4J0k3wsv7vtdpX3N7ZTvyWLOtTudwcw6Ba0hbMzbwp0
          #     9pLxuQyc75uEJ0WKVIIHwT5qvlu/7qfLw8dN1Tj766hek3GzNonE0mh6SBg/zVL6
          #     0+nPjBFoa+2g/u5+TA3uWX9R2ipqPxxXAt7bXIKhTJ3Dpu6eHn/r+ueaTy8hMgnj
          #     4AZZeni8Wp0kxS9bFyhsxFOKTWyBRlwreILJviq6zVIvTXlJlxljBOwPyAQHjRhP
          #     +dtoyisN2YSSBv8JKMFH1LOwkubbfs5QcQpHe48baiM48/Gz4vr93BpVPkY+c2z8
          #     ZSTc5NYOWF3CPJTCeHqxugzuzI0MOB7qE55Epqlet5L0Q6DNCjaS3JS46OGKKZEa
          #     gh2FGAJajXycQuUWuZHtClMAyDNKpi+4aOXLToktEbR5oubPaTFAJGFeHREGrpeG
          #     l4AzWBbNNJzCeie303Av1octfxQAS3tULC9VBZzt8TLNLRygzVBkLvm2z0BDdkeJ
          #     uH2h5eNFaL2DACt+n7PQGPV54t3ctNQzuD/psSxY8Uo85mfRmYzlHs1m6EHiq9Xg
          #     7T9JlDAFGBdZZjX+luFC7jTsoCEK6uidD58SaUHwo8NMwYvLDOV2iu04Fbj3zKrX
          #     hs5JdxUONPjG6o+/DT12EINS1lvBa06RDgqtDNzPl55bEfOwAQKCAQEA3vz9S0Um
          #     EjwPzhZh6dm3Q+QEqrifYxpkE0gW7rpBO9lsLyoJhCWEnTzUvQ6soT9w01cqUWQe
          #     jpUkCK8E26q7GgBsrNFFindKRCPDjHkr9mXTTSYNQnTl8yofubkjjlJR5uYA067g
          #     Q4fhxDjAVK/30FPM+OP/3H3eeF4t55t+k5ovUfWd5oNTkw2vvPck6bqLI+KmiQKa
          #     3FSA+I2nNrQa+wWEcdIGdJEaxBkXIzWUBALwwHHvH9V43uZVJEJpH26VpeV066/f
          #     XxT8PsqJpPg4YzVcotKc5KzuXWcSupIf9lz0BCArd62OaWBZIEARrAk3558i5P9A
          #     bGeiS0pY9/NHZQKCAQEA2CnqSCU0FgaD4/pxDemZ2HOGuQJw2CN5uyxlBY5OdYuz
          #     8KqPddaCeoeSxhV1Qoc5g0hHfURfw/QhGxPCq1paNOCgV+qCUqbjAZm0luuSJeQi
          #     QaIIYr1LgVgw704yk+nN5AVlzmKs1hZKkPT+7EfVrEJR2T/OlHaMIya+QvwK1TUA
          #     9ZuJuAx3JuBneEadgWAjetXUAZrppsp4BDJvXSw184VfxU8bq9KsWeUW0jeEIrcD
          #     ZkFo6Q9uwGsyIx0zPgtv6nzbfltQVxBOMS1T9h2nLpm3RRLXv8qwn3x2aIl6xV56
          #     wurt8hL80Swav4eXnkCIoJzKTMxycw+KspMfGngTAQKCAQBVWeal8fDRl/XAv2Z4
          #     +SGhtdxncEVpzIczritA8z/W5bD4GJIN58Jr4QXY244OJldMPZfwEW90yfdB76Pf
          #     ZOk62aC/QVbp2iEuFbZaxWKjbHRFmmQG5PHDcoM0Nn46kp3Q0IbOf6hNkOxEjChq
          #     AfTL49eYCMU9o1wNHJdbiHQZkTG9oFLxEaFiryFuJfcWE5YAhVeTJ9EYtquq96Vi
          #     Vevh20nHu0lHQudI2gW2L2LZajq2nqWVvMMIJoe+WkEci9px5nMrZ2ULYt/uNN4c
          #     q/oBV0J+/Dibeum+DJ7plNbxGME59wpMQ7037m4O3xckj167pHjZyC3jkINZaDrH
          #     pXHVAoIBAQCySfAITVcmi30g/iFdHj1b//0wf0jfnHL85GL2MCeaX/2sFKF6ydCY
          #     i1WNt4kdtDbFh0ofkdOC5cqgcK3xcvZQAq19ldijny5A1avThrzmL8HpbGGKPyMV
          #     rc2+szqYMRE2bxVHIq/3bC9YXBoefClKiPDFRRF39kcjfwMScJvmum7uJLl0aiOk
          #     lxYAaA3k9YyN9euE32azwO84VvjvWlWtY2ZYcSUblQm+o2stO8jqcRSGtJB5Gdd5
          #     MXEK8TygggJu30iScXJUPQihGwfTSSXpE7PLbv0wHVeMU7W+BxaRz5llRyu2q96G
          #     D+CH9KgjSIroHinlKgODz1/QZfQTetIBAoIBADQ6LW/LgCktUoROROwWQCre55ME
          #     NmcPqeEX7/qi4TY0oic1QEmKVof+65bijBwqqCuFWvjCX+XNkbcMDzRUm0Q4ZQnn
          #     m/unPz6SGOHc0NYY6RQlTQAHVHsmvj+rOwO4mxWKjwnixPVfBFAniFc59fu7ooSm
          #     6aAQJUHKIiMiAj849KcSdb9BsLjNQHVenJYm2IZrdlgisihY/OyiWZlGi8rNgySM
          #     UTKVAKxJU/hK7TitNodM8cfP+lwIITA5MUaDsSPY0feDzMK5Tecqipwyqztm2RqI
          #     c4K8QbMTx6Awc/BTqruNkJN2Ky0Ce8cyW1O02mytyPPLOaBO0zRMmFpEcfk=
          #     -----END RSA PRIVATE KEY-----
          #   certificate: |
          #     -----BEGIN CERTIFICATE-----
          #     MIIGhjCCBG6gAwIBAgIUUliLPK6R7OeviNDRY2dtI/G7YQIwDQYJKoZIhvcNAQEL
          #     BQAwgYwxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIDAZCZXJsaW4xHzAdBgNVBAoMFkZp
          #     d2FyZSBGb3VuZGF0aW9uIGUuVi4xCzAJBgNVBAsMAklUMRwwGgYDVQQDDBNGSVdB
          #     UkVfSU5URVJNRURJQVRFMSAwHgYJKoZIhvcNAQkBFhFmaXdhcmVAZml3YXJlLm9y
          #     ZzAeFw0yMjExMDkwNzU0MjBaFw0yNzExMDgwNzU0MjBaMIGkMQswCQYDVQQGEwJE
          #     RTEPMA0GA1UECAwGQmVybGluMQ8wDQYDVQQHDAZCZXJsaW4xEjAQBgNVBAoMCVNh
          #     dGVsbGl0ZTEYMBYGA1UEAwwPRklXQVJFU0FURUxMSVRFMSMwIQYJKoZIhvcNAQkB
          #     FhRzYXRlbGxpdGVAZml3YXJlLm9yZzEgMB4GA1UEBRMXRVUuRU9SSS5GSVdBUkVT
          #     QVRFTExJVEUwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC8SfhOKnws
          #     CpcxcGXzofaf5Oa1VASXDqv21lQQtWs9KBzoSJYDJ4DzH6MLIVbsNrTeugyF7D2y
          #     bgzqqQ19igeNj7PZYmbwlzQ/B9eQaRpAwjdNF4h1cQpXVCLSLa9/WwtxV6hTdTs/
          #     9er3tCiGi1fCe1Hggl/ykEC4OxYq3CAzmnfI7TwmI721oLdPXkbyM46IHbQOry/d
          #     KFXjjaf3yur46k9NfEc3Ed3W4vqdILVF1gjFUiY8EQVTNcR3RBXiaQgHyEcbfPcz
          #     lQOK67EyaA+mJ1gw0A5FFqeGFzu6vCPX/SfHUzHv0jAgyig2QOdMy5AD1EDs1F1D
          #     N0QRCSo4TIIrz97tA0Ou+F5qVu9JqYjeS9/Aobds9O/tRjAyg6tqVE0Th9Kyyxw9
          #     CJ3m1316JNpu4AIIJBHaEE/Eo9FZ/JZ/XrFn0SwdJogKtGX+ACuMtsIsuzQfhV4q
          #     cHZKWBG+btWFekqJQEk0A1uMV8Khoyg08hoo1Q+p1uPix2E0X6UAYDhGgdDxGxnD
          #     EZgBL4yQgjoWzDe/rAPBjvlchdPH9QUgUsxlVa8yiNuyx8pZb40yKRCSL4I5OWLk
          #     37/sYqxsljpobhJl390YE35LfhmqKZShVMnNDexQQ92o+LD7MPLhSrVqL0o/DDIl
          #     zuOdynlnyp5rAzDiBr/+BwDqYXhEv5fGZQIDAQABo4HFMIHCMAkGA1UdEwQCMAAw
          #     EQYJYIZIAYb4QgEBBAQDAgWgMDMGCWCGSAGG+EIBDQQmFiRPcGVuU1NMIEdlbmVy
          #     YXRlZCBDbGllbnQgQ2VydGlmaWNhdGUwHQYDVR0OBBYEFBwGLZR583u1g+bTzyl9
          #     lQsDLoa5MB8GA1UdIwQYMBaAFCdVXai4piVrVEDg/6LNuF4f0o0OMA4GA1UdDwEB
          #     /wQEAwIF4DAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwDQYJKoZIhvcN
          #     AQELBQADggIBAH9QGWANJEikCdoUAprRTbap2Yr44KUks3df/BawYnvWfTxBfhNZ
          #     5k9Fln5uGoOKb7MYmBAQ0ZuooPrb6srPZOEORdluxxbCgp9PoukOvLmHype13msA
          #     0yIvBuDLgPj5HesJ2dSdTwOThisZAov3B6+gt4MMt+4WPD24cfbB7sUgJWnTaKzC
          #     jivLdt+j/ymZFl41tb5kGcKv3OmYYTiy5V5DMxataZargN71mM0QElxR6kKWgkgK
          #     6slcvwMHOyn+o/DezgoUkdtA7gwa9sFnwHoxbId427BQd0BdtEVMyiQqutYquQbQ
          #     wwbB6K5+7rcpdsFRl7OzQmmll6SGKcjmm1stZANlZj41lWKg5IG0Xw+8Ei3lHL62
          #     imVFD1YgPuAAOcCkLpvnoAtcWvMInAhUMev8XukgrBO4tdyB8qteQelRLYYvWOf5
          #     gzscb/B2g18g4KtSM6IGd8/QzsU9dJE2e0VcXTgkIJgRVIX5VJy53YxHEsKOWqm7
          #     /t2baJSFLhS3aDmcC+BUtnQcOQzMTy+Idb96sU/pUdJCmJBlJ6g4Kg4zsZAiFbou
          #     ZUkzFO9WH+elKhqHZRw6MFFZ4Srb8JSpkCh7DP/H5XDKOCsGtgZKCHd1bC29mcer
          #     lYGR6nNL82ub8PwlYAom7eVFiwLpZwKp/hQoAtDF84bCNOwhQbIw3HTq
          #     -----END CERTIFICATE-----
          #     -----BEGIN CERTIFICATE-----
          #     MIIGAjCCA+qgAwIBAgIBATANBgkqhkiG9w0BAQsFADCBkzELMAkGA1UEBhMCREUx
          #     DzANBgNVBAgMBkJlcmxpbjEPMA0GA1UEBwwGQmVybGluMR8wHQYDVQQKDBZGaXdh
          #     cmUgRm91bmRhdGlvbiBlLlYuMQswCQYDVQQLDAJJVDESMBAGA1UEAwwJRklXQVJF
          #     X0NBMSAwHgYJKoZIhvcNAQkBFhFmaXdhcmVAZml3YXJlLm9yZzAeFw0yMjExMDkw
          #     NzM5MzdaFw0zMDAyMTAwNzM5MzdaMIGMMQswCQYDVQQGEwJERTEPMA0GA1UECAwG
          #     QmVybGluMR8wHQYDVQQKDBZGaXdhcmUgRm91bmRhdGlvbiBlLlYuMQswCQYDVQQL
          #     DAJJVDEcMBoGA1UEAwwTRklXQVJFX0lOVEVSTUVESUFURTEgMB4GCSqGSIb3DQEJ
          #     ARYRZml3YXJlQGZpd2FyZS5vcmcwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
          #     AoICAQDFawfVVoUqE/HYcgHNPjjK4xHA5ClWIx4lvXskCshK95KnePdkOSK8Lhp5
          #     sQB/K0A6bU9IA7LeNhloTQ1u+pn0H/ml0XAH+1QVmDURxy50mC0FKp4scMVsW6Ps
          #     21A2QaRYADZj9BjFt7UeuCWAtDXupuEw/+SPLnDByfY3nEnhOWerNfdXiAhp2STY
          #     pOa1A/OTARLWz/wJSrTynC7sWcE/QCW5YuK+kOH1KyUlFY/NLY+7n9E6rHte2hjG
          #     Sgie4EH7xps2VLcmJhKe5sUXWcmoPnIY42iNgMFcYy0xQT9oWY4fohL9Qy6yB30p
          #     yKFuuejF39ntB6VMJ0Jozg816CigJoP9yjNmNSLhNGCp9sqD83qnV5nIJtoQijCZ
          #     j15vYLdKvG7iM9jkOP09V9kY6QUWBeFTuHe0n77D4FMey6rC1GHeNXTwSOretbD9
          #     zl9Tx9BNPRsX9MNKoXif2sT2eKA0IJs2gUAPCncVORMax6YuXkdZKByhRitNl33p
          #     LLATANzdg2YgHwBeggY1HfFYDVc++t1cZUitHTKXeQ5YW+b2Rs+5+d/aNA8pAipG
          #     ZoML9GoE2lDPTFegjXn4vDg7FaVFIy6G1D6TWSmb6WJ6b+zAk3Gflc3wuYXtpI5Y
          #     x6ynpd++OZ7oVCcKmu7aSfE+K2kefd0MaIM28meu0qQ10j447QIDAQABo2YwZDAd
          #     BgNVHQ4EFgQUJ1VdqLimJWtUQOD/os24Xh/SjQ4wHwYDVR0jBBgwFoAUWcEwA+U0
          #     c5pQNn+5hlX5EhaiZCcwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMC
          #     AYYwDQYJKoZIhvcNAQELBQADggIBAETCN8uSZ+C7eTs4SsscUTivlw+eI6Zi7lvP
          #     AjRkHLSpCSkgtH5Ep+QtXLjj1li4OyLL81G6VvJqektr0CCk94AkxLy4DZHAWBtA
          #     vL0k8UYHvdhSZUBWhMcRum51g8yvVFIJCKPfOCsfzbjGKdOkv4T5RKBrAcFIFCvL
          #     dBl1j7dHRARtCy+Gyup4oPqlult5COtvTJJ7Yvd6Mmqg8TbDvD4C5vh7k6wT/ar+
          #     rlWiMJ8VG8CpEJD/7MGWP3woHRf6WUNLxj5VRsS+4O6b5cXsrrxog1YkkRN6ZDuH
          #     G8NdsdufE2JzK2wOlfxhGsgRIVheQqS3kgxXEpeFB8FXJKt57e+RD3fnqh8UA+ng
          #     3ghIanWL7kPI0/jQc8yxoZxAZ8pjiTuoU2JO7/eYHALJ/GFkDTkyDDKY2cbiVEFP
          #     FYM6lL3OV7dV99BRGclv2niuo2FfL/XTkUJPCeAnI7n9NgOKY+VXD5yEfAsLVqZm
          #     AAnJqYcdqN3WANfn30Q6wRiaimLSwRMY8g4DXsFy8xMiZcf4tKpLg/Ip/mUuMNZB
          #     tKpDMSCikMoQiuu1+AkkGtWImwvS3JnXipEA6ZuABYTHzIGEcc76T3sg9KIgZVKR
          #     a510g7F8CAaaAUkqXPpmWC0SXjZ50srIiFinaE8x45BElmWCHlcIT9gKzkatqbVO
          #     jDOUKVLp
          #     -----END CERTIFICATE-----
          #     -----BEGIN CERTIFICATE-----
          #     MIIGCTCCA/GgAwIBAgIUE4eZnRRqaub9kC+3PqDYNfVU8IcwDQYJKoZIhvcNAQEL
          #     BQAwgZMxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIDAZCZXJsaW4xDzANBgNVBAcMBkJl
          #     cmxpbjEfMB0GA1UECgwWRml3YXJlIEZvdW5kYXRpb24gZS5WLjELMAkGA1UECwwC
          #     SVQxEjAQBgNVBAMMCUZJV0FSRV9DQTEgMB4GCSqGSIb3DQEJARYRZml3YXJlQGZp
          #     d2FyZS5vcmcwHhcNMjIxMTA5MDcyNDU2WhcNMzIxMTA2MDcyNDU2WjCBkzELMAkG
          #     A1UEBhMCREUxDzANBgNVBAgMBkJlcmxpbjEPMA0GA1UEBwwGQmVybGluMR8wHQYD
          #     VQQKDBZGaXdhcmUgRm91bmRhdGlvbiBlLlYuMQswCQYDVQQLDAJJVDESMBAGA1UE
          #     AwwJRklXQVJFX0NBMSAwHgYJKoZIhvcNAQkBFhFmaXdhcmVAZml3YXJlLm9yZzCC
          #     AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOoPnXAtWFG6Bsdr4TvBUW12
          #     wpcRYH9fiDm5Mc6g6VdiL9I1tWMbhfO7DPyOaoqh6xloDL+XoeREmoIfJJpY3bdu
          #     zPswTinaMd7H+aMP6wWDsAIABhmw5Pui3UbpUZeFeo3RMe5f8JjL4KPgjWCX1llx
          #     O6yxy1e8gSfGpBkEHpJc8lKQwDE9zgyuiOLRUPRtSe0NJajcBrrXiaSPGdXvG39N
          #     YzjAARo5PAEBG+UHHzZFeS11MT+GbryZrx9KbdmVshdlsGqL/2sTY9veFrz53XLR
          #     Gmq86U+IQZEEvp6Z5k5ZwamBiACiRDbSwh1Ngp+BKNG26wCvB4gfxTOuSHIfzRkP
          #     D8vdV7mZwyeFHXogsNqF/8Pmdy0ONcqThh7w7lUFMVygk9q531n6QGRRpwCgKAjy
          #     jYN5r2Mo68+tmxNCejIPpo/JsAEKlPsh9lH7KhSEjIaHx//Q2f/nll1Z4GkXj7Sk
          #     ALz3P4ljT3ePeT2wnlSpyrCEPIeMXT47Z2xdc9MgXhqxidep7sUWFMaJwKhq1m1U
          #     JXI216GKUN3y//WSvRu7tqzyuUR9qsfY946EUF6m4XQjj9wke6H7vTpY9U/zwc9j
          #     yx+fXnJiuYht6k2cHav9GK0wnZ5Ct6A1+43eRR43EJ11OM9Ml+J4tdfukSrW6ppm
          #     z+4Yxfe5RRtzPeXxncjbAgMBAAGjUzBRMB0GA1UdDgQWBBRZwTAD5TRzmlA2f7mG
          #     VfkSFqJkJzAfBgNVHSMEGDAWgBRZwTAD5TRzmlA2f7mGVfkSFqJkJzAPBgNVHRMB
          #     Af8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4ICAQDGFxElC2Sq6/EOcbzQ7tjaqc5d
          #     v2FCWTTQYQLiS+VQqcJqGnMnEwWUDCeacQ6BaxdTW+jb1zX66DgfNJ40Yr2YDVv4
          #     qr+KKCW+q8cKQUte/XmcpLJtrXtYZQMeLUfwBlF2yAvmb3/2cda0VIhsem2BIFCE
          #     227+wOYqHSqpkqfVcizljnYLTwvTBQz5P0Jq9/wPcjB7fxfko2mZjaPQFfEuLPMT
          #     Jttv7711TJCrp0gzmnICS1Ba3vtcdZN+rd6IoSQmudnOcGDJkslL77T4BzjXDkax
          #     fuCoQ6f/hwXJuJF3fQHd6OsJHDgVAJQ78Nyb5P/2KMpdY/nkudeBG3ZcEJP7uptc
          #     QnWmMMLbfuGuXmAvXyKJJ3bw01F9+Vfo5OLud4IVnv0QDlXLHBDdGErBTT6m5XZN
          #     SyBXbqp1xIui+Jufm4HY0Y7kX0QzfSHdMXWgiIdmR8z0x15PQg/uFihXjp/RyqDr
          #     G+Tin3TXBqJRdDxYCwdnoutQnqtYCbsidoLv2ZA0vQiGfykPMpU49dGKwVCZBw1y
          #     Lf8X0QG5Vxp9O42jXzSy5rYwrF76FTpy+h7UqmZNOBXJG1roKrQWZ2OieFMp/rTD
          #     YURyhqWqqW2u7UehYs6emmSwYv8j0v4CzpH517jp2RJNyinI3TZmgD0AAKzyJAl/
          #     Zqat8t/baTS3TUdIKg==
          #     -----END CERTIFICATE-----

          #   trustedList:
          #     - name: FIWARE_CA
          #       crt: |
          #         -----BEGIN CERTIFICATE-----
          #         MIIGCTCCA/GgAwIBAgIUE4eZnRRqaub9kC+3PqDYNfVU8IcwDQYJKoZIhvcNAQEL
          #         BQAwgZMxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIDAZCZXJsaW4xDzANBgNVBAcMBkJl
          #         cmxpbjEfMB0GA1UECgwWRml3YXJlIEZvdW5kYXRpb24gZS5WLjELMAkGA1UECwwC
          #         SVQxEjAQBgNVBAMMCUZJV0FSRV9DQTEgMB4GCSqGSIb3DQEJARYRZml3YXJlQGZp
          #         d2FyZS5vcmcwHhcNMjIxMTA5MDcyNDU2WhcNMzIxMTA2MDcyNDU2WjCBkzELMAkG
          #         A1UEBhMCREUxDzANBgNVBAgMBkJlcmxpbjEPMA0GA1UEBwwGQmVybGluMR8wHQYD
          #         VQQKDBZGaXdhcmUgRm91bmRhdGlvbiBlLlYuMQswCQYDVQQLDAJJVDESMBAGA1UE
          #         AwwJRklXQVJFX0NBMSAwHgYJKoZIhvcNAQkBFhFmaXdhcmVAZml3YXJlLm9yZzCC
          #         AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOoPnXAtWFG6Bsdr4TvBUW12
          #         wpcRYH9fiDm5Mc6g6VdiL9I1tWMbhfO7DPyOaoqh6xloDL+XoeREmoIfJJpY3bdu
          #         zPswTinaMd7H+aMP6wWDsAIABhmw5Pui3UbpUZeFeo3RMe5f8JjL4KPgjWCX1llx
          #         O6yxy1e8gSfGpBkEHpJc8lKQwDE9zgyuiOLRUPRtSe0NJajcBrrXiaSPGdXvG39N
          #         YzjAARo5PAEBG+UHHzZFeS11MT+GbryZrx9KbdmVshdlsGqL/2sTY9veFrz53XLR
          #         Gmq86U+IQZEEvp6Z5k5ZwamBiACiRDbSwh1Ngp+BKNG26wCvB4gfxTOuSHIfzRkP
          #         D8vdV7mZwyeFHXogsNqF/8Pmdy0ONcqThh7w7lUFMVygk9q531n6QGRRpwCgKAjy
          #         jYN5r2Mo68+tmxNCejIPpo/JsAEKlPsh9lH7KhSEjIaHx//Q2f/nll1Z4GkXj7Sk
          #         ALz3P4ljT3ePeT2wnlSpyrCEPIeMXT47Z2xdc9MgXhqxidep7sUWFMaJwKhq1m1U
          #         JXI216GKUN3y//WSvRu7tqzyuUR9qsfY946EUF6m4XQjj9wke6H7vTpY9U/zwc9j
          #         yx+fXnJiuYht6k2cHav9GK0wnZ5Ct6A1+43eRR43EJ11OM9Ml+J4tdfukSrW6ppm
          #         z+4Yxfe5RRtzPeXxncjbAgMBAAGjUzBRMB0GA1UdDgQWBBRZwTAD5TRzmlA2f7mG
          #         VfkSFqJkJzAfBgNVHSMEGDAWgBRZwTAD5TRzmlA2f7mGVfkSFqJkJzAPBgNVHRMB
          #         Af8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4ICAQDGFxElC2Sq6/EOcbzQ7tjaqc5d
          #         v2FCWTTQYQLiS+VQqcJqGnMnEwWUDCeacQ6BaxdTW+jb1zX66DgfNJ40Yr2YDVv4
          #         qr+KKCW+q8cKQUte/XmcpLJtrXtYZQMeLUfwBlF2yAvmb3/2cda0VIhsem2BIFCE
          #         227+wOYqHSqpkqfVcizljnYLTwvTBQz5P0Jq9/wPcjB7fxfko2mZjaPQFfEuLPMT
          #         Jttv7711TJCrp0gzmnICS1Ba3vtcdZN+rd6IoSQmudnOcGDJkslL77T4BzjXDkax
          #         fuCoQ6f/hwXJuJF3fQHd6OsJHDgVAJQ78Nyb5P/2KMpdY/nkudeBG3ZcEJP7uptc
          #         QnWmMMLbfuGuXmAvXyKJJ3bw01F9+Vfo5OLud4IVnv0QDlXLHBDdGErBTT6m5XZN
          #         SyBXbqp1xIui+Jufm4HY0Y7kX0QzfSHdMXWgiIdmR8z0x15PQg/uFihXjp/RyqDr
          #         G+Tin3TXBqJRdDxYCwdnoutQnqtYCbsidoLv2ZA0vQiGfykPMpU49dGKwVCZBw1y
          #         Lf8X0QG5Vxp9O42jXzSy5rYwrF76FTpy+h7UqmZNOBXJG1roKrQWZ2OieFMp/rTD
          #         YURyhqWqqW2u7UehYs6emmSwYv8j0v4CzpH517jp2RJNyinI3TZmgD0AAKzyJAl/
          #         Zqat8t/baTS3TUdIKg==
          #         -----END CERTIFICATE-----
          additionalConfigs:
            logger:
              levels:
                ROOT: ERROR
                org.fiware.iam: DEBUG
        EOF
  ]

  depends_on = [helm_release.orion_ld]
}

#? DONE (any other configuration?)
resource "helm_release" "keyrock" {
  chart      = var.keyrock.chart_name
  version    = var.keyrock.version
  repository = var.keyrock.repository
  name       = local.keyrock_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "ClusterIP" # LoadBalancer for external access.
  }

  values = [
    <<EOF
        fullnameOverride: ${local.keyrock_service}

        # Admin keyrock user
        admin:
            user: admin
            password: ${var.keyrock.admin_password}
            email: ${var.keyrock.admin_email}
        
        # MySQL Database configuration
        db:
            user: root
            password: ${var.mysql.root_password}
            host: ${local.mysql_service}
        
        # External hostname of Keyrock
        host: https://keyrock.${var.ds_domain}

        # Port that the keyrock container uses
        port: 8080 # default port

        # Ingress configuration
        ingress:
            enabled: true
            annotations:
                kubernetes.io/ingress.class: "nginx"
                # forcing everything to use ssl
                ingress.kubernetes.io/ssl-redirect: "true"
                # example annotations, allowing cert-manager to automatically create tls-certs
                # kubernetes.io/tls-acme: "true"
            hosts:
              - host: keyrock.${var.ds_domain}
                paths:
                - /
            # configure the ingress' tls
            # tls:
              # - secretName: keyrock-tls
                # hosts:
                  # - keyrock.fiware.org
        
        # ## Configuration of Authorisation Registry (AR)
        # authorisationRegistry:
        #     # -- Enable usage of authorisation registry
        #     enabled: true
        #     # -- Identifier (EORI) of AR
        #     identifier: "did:web:my-did:did"
        #     # -- URL of AR
        #     url: "internal"

        # ## Configuration of iSHARE Satellite
        # satellite:
        #     # -- Enable usage of satellite
        #     enabled: true
        #     # -- Identifier (EORI) of satellite
        #     identifier: "EU.EORI.FIWARESATELLITE"
        #     # -- URL of satellite
        #     url: "https://tir.dataspace.com"
        #     # -- Token endpoint of satellite
        #     tokenEndpoint: "https://https://tir.dataspace.com/token"
        #     # -- Parties endpoint of satellite
        #     partiesEndpoint: "https://https://tir.dataspace.com/parties"

        ## -- Configuration of local key and certificate for validation and generation of tokens
        # token:
        #     # -- Enable storage of local key and certificate
        #     enabled: false

        # # ENV variables for Keyrock
        # additionalEnvVars:
        #     - name: IDM_TITLE
        #     value: "dsba AR"
        #     - name: IDM_DEBUG
        #     value: "true"
        #     - name: DEBUG
        #     value: "*"
        #     - name: IDM_DB_NAME
        #     value: ar_idm
        #     - name: IDM_DB_SEED
        #     value: "true"
        #     - name: IDM_SERVER_MAX_HEADER_SIZE
        #     value: "32768"
        #     - name: IDM_PR_CLIENT_ID
        #     value: "did:web:my-did:did"
        #     - name: IDM_PR_CLIENT_KEY
        #     valueFrom:
        #         secretKeyRef:
        #             name: vcwaltid-tls-sec
        #             key: tls.key
        #     - name: IDM_PR_CLIENT_CRT
        #     valueFrom:
        #         secretKeyRef:
        #             name: vcwaltid-tls-sec
        #             key: tls.crt
    EOF
  ]

  depends_on = [helm_release.mysql]
}

#FIXME: Error deployment!!
# {"level":"warning","msg":"Invalid LOG_REQUESTS configured, will enable request logging by default. Err: strconv.ParseBool: parsing \"\": invalid syntax.","time":"2024-02-14T13:33:46Z"}
# {"level":"warning","msg":"Issuer repository is kept in-memory. No persistence will be applied, do NEVER use this for anything but development or testing!","time":"2024-02-14T13:33:46Z"}
# {"level":"info","msg":"iShare is enabled.","time":"2024-02-14T13:33:46Z"}
# {"level":"info","msg":"Will use the delegtion address https://ar.isharetest.net/delegation.","time":"2024-02-14T13:33:46Z"}
# {"level":"info","msg":"Will use the token address https://ar.isharetest.net/connect/token.","time":"2024-02-14T13:33:46Z"}
# {"level":"warning","msg":"Was not able to parse the key . err: Invalid Key: Key must be a PEM encoded PKCS1 or PKCS8 key","time":"2024-02-14T13:33:46Z"}
# {"level":"fatal","msg":"Was not able to read the rsa private key from /iShare/key.pem, err: Invalid Key: Key must be a PEM encoded PKCS1 or PKCS8 key","time":"2024-02-14T13:33:46Z"}
resource "helm_release" "dsba_pdp" {
  chart      = var.pdp.chart_name
  version    = var.pdp.version
  repository = var.pdp.repository
  name       = local.pdp_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    <<EOF
      db: 
        enabled: false
        migrate:
          enabled: false
      # deployment:
        # image:  
        #   pullPolicy: Always
        #   repository: quay.io/fiware/dsba-pdp 
        #   tag: 1.0.0
        logLevel: DEBUG
        # ishare: #! What is this??
        #   existingSecret: dsba-onboarding-portal-walt-id-vcwaltid-tls-sec

        #   clientId: did:web:onboarding.dsba.fiware.dev:did
        #   trustedFingerprints:
        #     - D2F62092F982CF783D4632BD86FA86C3FBFDB2D8C8A58BC6809163FCF5CD030B

        #   ar:
        #     id: "did:web:onboarding.dsba.fiware.dev:did"
        #     delegationPath: "/ar/delegation"
        #     tokenPath: "/oauth2/token"
        #     url: "https://ar.dsba.fiware.dev"

        #   trustAnchor:
        #     id: "EU.EORI.FIWARESATELLITE"
        #     tokenPath: "/token"
        #     trustedListPath: "/trusted_list"
        #     url: "https://tir.dsba.fiware.dev"
            
        # trustedVerifiers:
        #   - https://${local.verifier_service}/.well-known/jwks

        # providerId: "did:web:onboarding.dsba.fiware.dev:did"
        
      # additionalEnvVars:
      #   - name: ISHARE_CERTIFICATE_PATH
      #     value: /iShare/tls.crt
      #   - name: ISHARE_KEY_PATH
      #     value: /iShare/tls.key
    EOF
  ]

  depends_on = [helm_release.keyrock, helm_release.verifier]
}

#? Where are the Orion and PDP services referred to?
#FIXME: Error deployment!!
# Defaulted container "proxy" out of: proxy, clear-stale-pid (init)
# Error from server (BadRequest): container "proxy" in pod "ds-operator-kong-kong-67fc695f5d-pfgkv" is waiting to start: PodInitializing
resource "helm_release" "kong" {
  chart      = var.kong.chart_name
  version    = var.kong.version
  repository = var.kong.repository
  name       = local.kong_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  values = [
    <<EOF
        # image:
        #   repository: quay.io/fiware/kong
        #   tag: "0.5.2"
        #   pullPolicy: IfNotPresent

        # replicaCount: 1

        autoscaling:
          enabled: false

        admin:
          enabled: true
          type: ClusterIP  
          http: 
            enabled: true
            servicePort: 8001
            containerPort: 8001

        status:
          enabled: true
          http: 
            enabled: true
            containerPort: 9102

        podAnnotations:
          prometheus.io/scrape: 'true'
          prometheus.io/port: '9102'

        dblessConfig:
          configMap: kong-one-configmap
        
        env:
          database: "off"
          nginx_worker_processes: "2"
          proxy_access_log: /dev/stdout
          admin_access_log: /dev/stdout
          admin_gui_access_log: /dev/stdout
          portal_api_access_log: /dev/stdout
          proxy_error_log: /dev/stderr
          admin_error_log: /dev/stderr
          admin_gui_error_log: /dev/stderr
          portal_api_error_log: /dev/stderr
          prefix: /kong_prefix/
          log_level: debug
          nginx_proxy_large_client_header_buffers: "16 128k"
          nginx_proxy_http2_max_field_size: "32k"
          nginx_proxy_http2_max_header_size: "32k"
          plugins: bundled,pep-plugin,ngsi-ishare-policies
          pluginserver_names: pep-plugin
          pluginserver_pep_plugin_start_cmd: "/go-plugins/pep-plugin"
          pluginserver_pep_plugin_query_cmd: "/go-plugins/pep-plugin -dump"

        ingressController:
          enabled: false
          installCRDs: false
        
        proxy:
          type: ClusterIP
          enabled: true
          tls:
            enabled: false
          # Ingress configuration
          ingress:
              enabled: true
              annotations:
                  kubernetes.io/ingress.class: "nginx"
                  # forcing everything to use ssl
                  ingress.kubernetes.io/ssl-redirect: "true"
                  # example annotations, allowing cert-manager to automatically create tls-certs
                  # kubernetes.io/tls-acme: "true"
              hosts:
                - host: kong.${var.ds_domain}
                  paths:
                  - /
              # # configure the ingress' tls
              # tls:
              #   - secretName: keyrock-tls
              #     hosts:
              #       - keyrock.fiware.org
                      
    EOF
  ]

  depends_on = [helm_release.orion_ld] #, helm_release.dsba_pdp]

}

#* DONE
resource "helm_release" "credentials_config_service" {
  chart      = var.credentials_config_service.chart_name
  version    = var.credentials_config_service.version
  repository = var.credentials_config_service.repository
  name       = local.ccs_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [<<EOF
        database:
            persistence: true
            host: ${local.mysql_service}
            name: ${var.mysql.ccs_db}
            username: root
            password: ${var.mysql.root_password}
        EOF
  ]

  depends_on = [helm_release.mysql]
}

#? Ingress is needed?
resource "helm_release" "trusted_issuers_list" {
  chart      = var.trusted_issuers_list.chart_name
  version    = var.trusted_issuers_list.version
  repository = var.trusted_issuers_list.repository
  name       = local.til_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    <<EOF
        database:
            persistence: true
            host: ${local.mysql_service}
            name: ${var.mysql.til_db}
            username: root
            password: ${var.mysql.root_password}

        # ingress:
        #     til:
        #         enabled: true
        #         annotations:
        #             kubernetes.io/ingress.class: "nginx"
        #             # forcing everything to use ssl
        #             ingress.kubernetes.io/ssl-redirect: "true"
        #             # example annotations, allowing cert-manager to automatically create tls-certs
        #             # kubernetes.io/tls-acme: "true"
        #         hosts:
        #             - host: til.${var.ds_domain}
        #               paths:
        #                 - /
        #         # configure the ingress' tls
        #         # tls:
        #         #     - secretName: til-tls
        #         #       hosts:
        #         #           - til.fiware.org
        #     tir:
        #         enabled: true
        #         annotations:
        #             kubernetes.io/ingress.class: "nginx"
        #             # forcing everything to use ssl
        #             ingress.kubernetes.io/ssl-redirect: "true"
        #             # example annotations, allowing cert-manager to automatically create tls-certs
        #             # kubernetes.io/tls-acme: "true"
        #         hosts:
        #             - host: tir.${var.ds_domain}
        #               paths:
        #                 - /
        #         # configure the ingress' tls
        #         # tls:
        #         #     - secretName: tir-tls
        #         #       hosts:
        #         #           - tir.fiware.org
    EOF
  ]

  depends_on = [helm_release.mysql]
}

#? Ingress is needed? did configuration?
resource "helm_release" "walt_id" {
  chart            = var.walt_id.chart_name
  version          = var.walt_id.version
  repository       = var.walt_id.repository
  name             = local.waltid_service
  namespace        = var.namespace
  create_namespace = true

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    <<EOF
        # Organisation DID
        # did: did:web:my-did:did

        # Walt-id config
        vcwaltid:
          # API config
          api:
            core: 
              enabled: true
            auditor: 
              enabled: true
            signatory: 
              enabled: true
            custodian: 
              enabled: true
            essif: 
              enabled: true
          # Persistence
          persistence: 
            enabled: true
            pvc:
              size: 1Gi
        
        # # Ingress configuration
        # ingress:
        #     enabled: true
        #     annotations:
        #         kubernetes.io/ingress.class: "nginx"
        #         # forcing everything to use ssl
        #         ingress.kubernetes.io/ssl-redirect: "true"
        #         # example annotations, allowing cert-manager to automatically create tls-certs
        #         # kubernetes.io/tls-acme: "true"
        #     hosts:
        #       - host: waltid.${var.ds_domain}
        #         paths:
        #         - /
        #     # configure the ingress' tls
        #     # tls:
        #       # - secretName: keyrock-tls
        #         # hosts:
        #           # - keyrock.fiware.org
        

          # # List of templates to be created
          # templates:
          #   GaiaXParticipantCredential.json: |
          #     {
          #       "@context": [
          #         "https://www.w3.org/2018/credentials/v1",
          #         "https://registry.lab.dsba.eu/development/api/trusted-shape-registry/v1/shapes/jsonld/trustframework#"
          #       ],
          #       "type": [
          #         "VerifiableCredential"
          #       ],
          #       "id": "did:web:raw.githubusercontent.com:egavard:payload-sign:master",
          #       "issuer": "did:web:raw.githubusercontent.com:egavard:payload-sign:master",
          #       "issuanceDate": "2023-03-21T12:00:00.148Z",
          #       "credentialSubject": {
          #         "id": "did:web:raw.githubusercontent.com:egavard:payload-sign:master",
          #         "type": "gx:LegalParticipant",
          #         "gx:legalName": "dsba compliant participant",
          #         "gx:legalRegistrationNumber": {
          #           "gx:vatID": "MYVATID"
          #         },
          #         "gx:headquarterAddress": {
          #           "gx:countrySubdivisionCode": "BE-BRU"
          #         },
          #         "gx:legalAddress": {
          #           "gx:countrySubdivisionCode": "BE-BRU"
          #         },
          #         "gx-terms-and-conditions:gaiaxTermsAndConditions": "70c1d713215f95191a11d38fe2341faed27d19e083917bc8732ca4fea4976700"
          #       }
          #     }
    EOF
  ]

}

#? Ingress is needed? certificates configuration?
resource "helm_release" "verifier" {
  chart      = var.verifier.chart_name
  version    = var.verifier.version
  repository = var.verifier.repository
  name       = local.verifier_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    <<EOF
        deployment:
          # image:
          #   repository: quay.io/fiware/vcverifier
          #   tag: 2.7.0-pre-26
          #   pullPolicy: Always
          logging: 
            level: DEBUG
            pathsToSkip: 
              - "/health"
          server:
            host: https://verifier.${var.ds_domain}
          ssikit:
            auditorUrl: http://${local.waltid_service}:7003
          verifier:
            tirAddress: https://${local.tpr_service}/v3/issuers
            # did: did:web:onboarding.dsba.fiware.dev:did
          # m2m:
          #   authEnabled: true
          #   keyPath: /opt/did/secret/tls.key
          #   credentialPath: /opt/credential/c127.0.0.1       waltid.ds-operator.ioredential.json
          #   clientId: tir-res
          #   verificationMethod: did:web:onboarding.dsba.fiware.dev:did#54134df8357d4aaea1e600f3d0ebe7fb
          configRepo:
            configEndpoint: http://${local.ccs_service}:8080/
          # initContainers:
          #   - name: load-did
          #     image: quay.io/opencloudio/curl:4.2.0-build.8
          #     imagePullPolicy: Always
          #     command: 
          #       - /bin/sh
          #       - /opt/did/script/import.sh
          #     env:
          #       - name: WALTID_CORE_ADDRESS
          #         value: "${local.waltid_service}:7000"
          #     volumeMounts:
          #       - name: dsba-onboarding-did-config
          #         mountPath: /opt/did/script
          #       - name: did-secret
          #         mountPath: /opt/did/secret
          # additionalVolumeMounts:
          #   - name: ${local.verifier_service}
          #     mountPath: /opt/credential
          #   - name: did-secret
          #     mountPath: /opt/did/secret
          # additionalVolumes:
          #   - name: ${var.namespace}-did-config
          #     configMap:
          #       name: ${var.namespace}-did-config
          #   - name: ${local.verifier_service}
          #     configMap:
          #       name: ${local.verifier_service}
          #   # - name: did-secret
          #   #   secret: 
          #   #     secretName: dsba-onboarding-portal-verifier-vcverifier-tls-sec

        # Ingress configuration
        ingress:
            enabled: true
            annotations:
                kubernetes.io/ingress.class: "nginx"
                # forcing everything to use ssl
                ingress.kubernetes.io/ssl-redirect: "true"
                # example annotations, allowing cert-manager to automatically create tls-certs
                # kubernetes.io/tls-acme: "true"
            hosts:
              - host: verifier.${var.ds_domain}
                paths:
                - /
            # configure the ingress' tls
            # tls:
              # - secretName: keyrock-tls
                # hosts:
                  # - keyrock.fiware.org
  
    EOF
  ]

  depends_on = [helm_release.credentials_config_service, helm_release.walt_id, helm_release.trusted_issuers_list]
}

