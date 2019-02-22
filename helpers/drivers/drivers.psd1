@{
    Drivers = @(
        @{ IHV = 'Broadcom' ; DriverFileName = 'bnxtnd.sys'    ; MinimumDriverVersion = '212.0.88.0'    }, # NetXtreme
        @{ IHV = 'Broadcom' ; DriverFileName = 'ocndnd.sys'    ; MinimumDriverVersion = '11.0.273.8008' }, # OneConnect
    
        @{ IHV = 'Cavium'   ; DriverFileName = 'bnadi.sys'     ; MinimumDriverVersion = '3.2.26.1'      }, # BR-series
        @{ IHV = 'Cavium'   ; DriverFileName = 'bxvbda.sys'    ; MinimumDriverVersion = '7.12.31.105'   }, # BCM57***
        @{ IHV = 'Cavium'   ; DriverFileName = 'bxnd60a.sys'   ; MinimumDriverVersion = '7.13.57.103'   }, # BCM57***
    #   @{ IHV = 'Cavium'   ; DriverFileName = 'evbda.sys'     ; MinimumDriverVersion = 'TODO'          }, # BCM57***
        @{ IHV = 'Cavium'   ; DriverFileName = 'qevbda.sys'    ; MinimumDriverVersion = '8.33.20.103'   }, # FastLinQ
        @{ IHV = 'Cavium'   ; DriverFileName = 'qenda.sys'     ; MinimumDriverVersion = '8.22.18.105'   }, # FastLinQ
    
        @{ IHV = 'Chelsio'  ; DriverFileName = 'cht4nx64.sys'  ; MinimumDriverVersion = '6.9.12.400'    }, # Chelsio
    
    #   @{ IHV = 'Intel'    ; DriverFileName = 'e1y60x64.sys'  ; MinimumDriverVersion = 'TODO'          }, # 82567
        @{ IHV = 'Intel'    ; DriverFileName = 'i40ei65.sys'   ; MinimumDriverVersion = '1.8.103.2'     }, # X710
        @{ IHV = 'Intel'    ; DriverFileName = 'ixi65x64.sys'  ; MinimumDriverVersion = '4.1.77.1'      }, # 82599 / x520
        @{ IHV = 'Intel'    ; DriverFileName = 'v40e65.sys'    ; MinimumDriverVersion = '1.5.85.2'      }, # X722
        @{ IHV = 'Intel'    ; DriverFileName = 'vxn63x64.sys'  ; MinimumDriverVersion = '1.1.215.0'     }, # X540
    
        @{ IHV = 'Mellanox' ; DriverFileName = 'mlx4eth63.sys' ; MinimumDriverVersion = '5.50.14643.0'  }, # ConnectX-3
        @{ IHV = 'Mellanox' ; DriverFileName = 'mlx5.sys'      ; MinimumDriverVersion = '1.90.19240.0'  }  # ConnectX-4
    )
}