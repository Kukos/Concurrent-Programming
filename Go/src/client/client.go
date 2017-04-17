/*
    This Package contains functions of Client to talk with user
    Author: Michal Kukowski
    email: michalkukowski10@gmail.com
    LICENCE: GPL3.0
*/
package client

import (
    "fmt"
    "configs"
    "train"
    "myswitch"
    "track"
    "os"
    "os/exec"
)

func clearScreen() {
    c := exec.Command("clear")
    c.Stdout = os.Stdout
    c.Run()
}

func Talk() {
    var cmd int
    for {
        fmt.Println("Enter Command:")
        fmt.Println("[1]    Print Configs")
        fmt.Println("[2]    Print Trains")
        fmt.Println("[3]    Print Tracks")
        fmt.Println("[4]    Print Switches")
        fmt.Println("[5]    Print Trains Posision")
        fmt.Println("[6]    Exit")

        _, _ = fmt.Scanf("%d", &cmd)

        /* Clear screen */
        clearScreen()

        switch cmd {
        case 1:
            configs.Conf.Show()
        case 2:
            train.Trains.Show()
        case 3:
            track.Tracks.Show()
        case 4:
            myswitch.Switches.Show()
        case 5:
            train.Trains.ShowPos()
        case 6:
            os.Exit(0)
        }
    }
}
