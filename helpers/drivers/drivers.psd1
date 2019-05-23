@{
    Drivers = @(
        @{ IHV = 'Broadcom' ; DriverFileName = 'bnxtnd.sys'    ; MinimumDriverVersion = '212.0.88.0'    }, # NetXtreme
        @{ IHV = 'Broadcom' ; DriverFileName = 'ocndnd.sys'    ; MinimumDriverVersion = '11.0.273.8008' }, # OneConnect
        @{ IHV = 'Chelsio'  ; DriverFileName = 'chnetx64.sys'  ; MinimumDriverVersion = '6.14.0.0'      }, # Chelsio
        @{ IHV = 'Intel'    ; DriverFileName = 'v40e65.sys'    ; MinimumDriverVersion = '1.5.85.2'      }, # Intel X722
        @{ IHV = 'Marvell'  ; DriverFileName = 'qevbda.sys'    ; MinimumDriverVersion = '8.33.20.103'   }, # FastLinQ
        @{ IHV = 'Marvell'  ; DriverFileName = 'qenda.sys'     ; MinimumDriverVersion = '8.22.18.105'   }, # FastLinQ
        @{ IHV = 'Mellanox' ; DriverFileName = 'mlx4eth63.sys' ; MinimumDriverVersion = '5.50.14688.0'  }, # ConnectX-3
        @{ IHV = 'Mellanox' ; DriverFileName = 'mlx5.sys'      ; MinimumDriverVersion = '2.20.21096.0'  }  # ConnectX-4
    )
}