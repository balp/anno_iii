workspace {
    model {
        anno = group "Anno III" {
            navigator = person "Navigator" "The ships navigator, planns the route of the ship"
            helmsman = person "Helmsman" "The helmsman, does tha actuall stearing of the ship"
    
        
            navigation = softwareSystem "Navigation system" "Keeps track of the ships location and planned route " {
                n2k = group "N2K" {
                    gwind = container "gWind™ Transducer"
                    gst43 = container "GST 43" "speed and temperature transducer"
                    gdt43 = container "GDT 43" "Depth Transducer"
        
                    gnx_wind = container "GNX™ Wind"
                    gnx_20 = container "GNX™ 20"
                    v60_b = container "B&G V60-B VHF"
                    signalk = container "SignalK Server" {
                        component "NodeJS Server"
                        component "N2K Plugin"
                    }
                }
                boating = container "Boating application"
                opencpn = container "OpenCPN"
    
                autopilot = container "Raymarine ST Autopilot"


                v60_b -> gnx_20 "Send boat position"
                v60_b -> signalk "Send boat position"
    
                gwind -> gnx_wind "Send wind speed and direction"
                gwind -> gnx_20 "Send wind speed and direction"
                gst43 -> gnx_20 "send ship speed"
                gdt43 -> gnx_20 "send water depth"
    
                gwind -> signalk "Send wind speed and direction"
                gst43 -> signalk "send ship speed"
                gdt43 -> signalk "send water depth"
    
                helmsman -> gnx_wind "Gets wind data to trim sails"
                helmsman -> gnx_20 "Get course and planned heading"
                helmsman -> boating "View currect sea charts"
                navigator -> opencpn "Plan routes"
                opencpn -> boating "Export planned routes (GPX Files)"
                signalk -> boating "Provide realtime ship data"
                signalk -> opencpn "Provide realtime ship data"
    
                helmsman -> autopilot "Enter planned course"
            }
            engine = softwareSystem "Engine" "Provides propulsion to the ship" {
                start_engine = container "Start Engine"
                main_engine = container "Main engine"
                alternator = container "Alternator"
            }
            sails = softwareSystem "Sails" "Provides propulsion to the ship" {
            }
            electric = softwareSystem "Electric system" "Provides power to other parts of the ship" {
                house_battery_bank = container "House Battery Bank"
                start_battery_bank = container "Start Battery Bank"

                shore_power = container "Shore Power"
                shore_charger = container "Blue Smart IP22"
                solar_charger = container "BlueSolar"
                bt_solar_charger = container "Biltema Solar Charger"
                power_outlets = container "220v Outlets"
                solar_panel_1 = container "100w top solar panel"
                solar_panel_2 = container "25w rear solar panel"

                house_battery_bank -> signalk "Provides power"
                house_battery_bank -> gwind "Provides power"
                house_battery_bank -> gst43 "Provides power"
                house_battery_bank -> gdt43 "Provides power"
                house_battery_bank -> gnx_wind "Provides power"
                house_battery_bank -> v60_b "Provides power"
                house_battery_bank -> boating "Provides power"
                house_battery_bank -> opencpn "Provides power"

                start_battery_bank -> start_engine "Provides power"
                alternator -> start_battery_bank "Charges"
                alternator -> house_battery_bank "Charges"
                shore_power -> shore_charger "Provides Power"
                shore_power -> power_outlets "Provides Power"
                shore_charger -> house_battery_bank "Charges"
                solar_charger -> house_battery_bank "Charges"
                bt_solar_charger -> house_battery_bank "Charges"

                solar_panel_1 -> solar_charger "Gets sun energy"
                solar_panel_2 -> bt_solar_charger "Gets sun energy"

            }
    

            helmsman -> engine "Operates the engine"
            helmsman -> sails "Operates the sails"
        }
        at_sea = deploymentEnvironment "Anno III" {
            deploymentNode "RPi4" {
                instances "1"
                containerInstance signalk
                containerInstance opencpn
            }
            deploymentNode "Instrumentpanel" {
                instances "1"
                containerInstance v60_b
                containerInstance gnx_wind
                containerInstance gnx_20
            }
        }
    }
    views {
        systemLandscape systemLandscape {
            include *
            autolayout lr
        }

        systemContext navigation systemContext_navigation {
            include *
            autolayout lr
        }

        container navigation container_navigation {
            include *
            exclude "electric"
            autolayout lr
        }
        component signalk component_signalk {
            include *
            autolayout lr
        }

        systemContext electric systemContext_electric {
            include *
            autolayout lr
        }
        container electric container_electric {
            include *
            autolayout lr
        }

        dynamic navigation dynamic_sail_autopilot {
            title "Sailing with autopilot"
            v60_b -> signalk "Position and AIS Traffic"
            signalk -> boating "Provides Position and AIS"
            gnx_20 -> helmsman "Provides, Speed & Depth Data"
            gnx_wind -> helmsman "Provides, Wind angle and speed"
            boating -> helmsman "Provides, Seachart, routing, AIS"
            helmsman -> sails "Adjust sail trim"
            helmsman -> autopilot "Adjust couse data"

            autolayout lr
        }
        
        deployment navigation at_sea deployment_live_navigation {
            include *
            autolayout lr
        }

        theme default
    }
}