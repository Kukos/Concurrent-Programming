/*
   This Package contains funtion of Reapir Team
   Author: Michal Kukowski
   email: michalkukowski10@gmail.com
   LICENCE: GPL3.0
*/

package repairteam

import (
	"configs"
	"fmt"
	"graph"
	"math/rand"
	"myswitch"
	"sync"
	"time"
	"track"
	"train"
)

var brokenItems int

// RepairNodeStation graph node for team
var RepairNodeStation *graph.Node
var useItemMutex sync.Mutex

func init() {
	rand.Seed(time.Now().UTC().UnixNano())
	brokenItems = 0
}

func genRand(min int, max int) int {
	return min + rand.Intn(max)
}

// UseItem use an object in graph
func UseItem(n *graph.Node) {
	useItemMutex.Lock()

	if brokenItems == 0 && genRand(1, 100) <= configs.Conf.Probability() {
		if n.Type() == graph.VERTEX {
			myswitch.Switches.GetSwitchByID(n.ID()).Breaking()
		} else {
			track.Tracks.GetTrackByID(n.ID()).Breaking()
		}

		brokenItems = 1

		path := graph.FindPath(RepairNodeStation, n)
		go startRepair(path, n)
	}

	useItemMutex.Unlock()
}

func reservePath(path *graph.Path) {
	for i := 0; i < len(path.Array); i++ {
		if path.Array[i].ID() != 0 {
			if path.Array[i].Type() == graph.EDGE {
				track.Tracks.GetTrackByID(path.Array[i].ID()).Busy()
				if configs.Conf.Mode() == configs.NOISY {
					fmt.Printf("<><><> TRACK %d IS LOCKED <><><>\n", track.Tracks.GetTrackByID(path.Array[i].ID()).ID())
				}
			} else {
				myswitch.Switches.GetSwitchByID(path.Array[i].ID()).Busy()
				if configs.Conf.Mode() == configs.NOISY {
					fmt.Printf("<><><> SWITCH %d IS LOCKED <><><>\n", myswitch.Switches.GetSwitchByID(path.Array[i].ID()).ID())
				}
			}
		}
	}
}

func startRepair(path *graph.Path, n *graph.Node) {

	/* resever Path */
	reservePath(path)

	if configs.Conf.Mode() == configs.NOISY {
		fmt.Println("/\\/\\/\\ REPAIR TEAM ARE GOING TO BROKEN NODE /\\/\\/\\")
	}

	var wTime float64
	var speed int
	t := train.Trains.GetTrainByID(configs.Conf.NumTrains())

	/* Go to Node */
	for i := 0; i < len(path.Array); i++ {
		if path.Array[i].ID() != 0 {
			if path.Array[i].Type() == graph.EDGE {
				/* get new Track */
				tr := track.Tracks.GetTrackByID(path.Array[i].ID())

				/* if is a station */
				if tr.Type() == track.STATION {
					t.ChangePos(train.POS_STATION, path.Array[i].ID())

					/* print info */
					if configs.Conf.Mode() == configs.NOISY {
						fmt.Printf("### [ %d ]    GO TO STATION: %d\n", t.ID(), tr.ID())
					}

					wTime = 0
				} else { /* it's normal track, so let's go */
					t.ChangePos(train.POS_TRACK, path.Array[i].ID())

					/* print info */
					if configs.Conf.Mode() == configs.NOISY {
						fmt.Printf("### [ %d ]    GO TO TRACK: %d\n", t.ID(), tr.ID())
					}

					/* our speed is min speed of train speed and track speed */
					if tr.Speed() < t.MaxSpeed() {
						speed = tr.Speed()
					} else {
						speed = t.MaxSpeed()
					}

					wTime = float64(tr.Len()) / float64(speed) * float64(configs.Conf.SPerH())
				}

				/* time for driving or waiting for people */
				time.Sleep(time.Duration(wTime * float64(time.Second)))

				/* Free Track */
				tr.Free()

				/* Print info */
				if configs.Conf.Mode() == configs.NOISY {
					if tr.Type() == track.NORMAL {
						fmt.Printf("@@@ [ %d ]    LEAVING TRACK %d\n", t.ID(), tr.ID())
					} else {
						fmt.Printf("@@@ [ %d ]    LEAVING STATION %d\n", t.ID(), tr.ID())
					}
				}
			} else {
				/* enter switch */
				s := myswitch.Switches.GetSwitchByID(path.Array[i].ID())
				t.ChangePos(train.POS_SWITCH, s.ID())

				/* print info */
				if configs.Conf.Mode() == configs.NOISY {
					fmt.Printf("### [ %d ]    GO TO SWITCH: %d\n", t.ID(), s.ID())
				}

				/* wait */
				wTime = float64(s.StayTime()) * float64(configs.Conf.SPerH())
				time.Sleep(time.Duration(wTime * float64(time.Second)))

				/* go out */
				s.Free()

				/* print info */
				if configs.Conf.Mode() == configs.NOISY {
					fmt.Printf("@@@ [ %d ]    LEAVING SWITCH: %d\n", t.ID(), s.ID())
				}
			}
		}
	}

	/* repair node */
	if n.Type() == graph.EDGE {
		track.Tracks.GetTrackByID(n.ID()).Fix()
	} else {
		myswitch.Switches.GetSwitchByID(n.ID()).Fix()
	}

	if configs.Conf.Mode() == configs.NOISY {
		fmt.Println("/\\/\\/\\ REPAIR TEAM ARE COMING BACK TO STATION /\\/\\/\\")
	}

	/* Come back */
	for i := len(path.Array) - 1; i >= 0; i-- {
		if path.Array[i].ID() != 0 {
			if path.Array[i].Type() == graph.EDGE {
				/* get new Track */
				tr := track.Tracks.GetTrackByID(path.Array[i].ID())

				tr.Busy()
				/* if is a station */
				if tr.Type() == track.STATION {
					t.ChangePos(train.POS_STATION, path.Array[i].ID())

					/* print info */
					if configs.Conf.Mode() == configs.NOISY {
						fmt.Printf("### [ %d ]    GO TO STATION: %d\n", t.ID(), tr.ID())
					}

					wTime = 0
				} else { /* it's normal track, so let's go */
					t.ChangePos(train.POS_TRACK, path.Array[i].ID())

					/* print info */
					if configs.Conf.Mode() == configs.NOISY {
						fmt.Printf("### [ %d ]    GO TO TRACK: %d\n", t.ID(), tr.ID())
					}

					/* our speed is min speed of train speed and track speed */
					if tr.Speed() < t.MaxSpeed() {
						speed = tr.Speed()
					} else {
						speed = t.MaxSpeed()
					}

					wTime = float64(tr.Len()) / float64(speed) * float64(configs.Conf.SPerH())
				}

				/* time for driving or waiting for people */
				time.Sleep(time.Duration(wTime * float64(time.Second)))

				/* Free Track */
				tr.Free()

				/* Print info */
				if configs.Conf.Mode() == configs.NOISY {
					if tr.Type() == track.NORMAL {
						fmt.Printf("@@@ [ %d ]    LEAVING TRACK %d\n", t.ID(), tr.ID())
					} else {
						fmt.Printf("@@@ [ %d ]    LEAVING STATION %d\n", t.ID(), tr.ID())
					}
				}
			} else {
				/* enter switch */
				s := myswitch.Switches.GetSwitchByID(path.Array[i].ID())
				s.Busy()
				t.ChangePos(train.POS_SWITCH, s.ID())

				/* print info */
				if configs.Conf.Mode() == configs.NOISY {
					fmt.Printf("### [ %d ]    GO TO SWITCH: %d\n", t.ID(), s.ID())
				}

				/* wait */
				wTime = float64(s.StayTime()) * float64(configs.Conf.SPerH())
				time.Sleep(time.Duration(wTime * float64(time.Second)))

				/* go out */
				s.Free()

				/* print info */
				if configs.Conf.Mode() == configs.NOISY {
					fmt.Printf("@@@ [ %d ]    LEAVING SWITCH: %d\n", t.ID(), s.ID())
				}
			}
		}
	}

	if configs.Conf.Mode() == configs.NOISY {
		fmt.Println("/\\/\\/\\ REPAIR TEAM ARE IN HOME /\\/\\/\\")
	}

	brokenItems = 0
}
