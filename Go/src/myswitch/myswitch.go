/*
   This Package contains functions of our Switch
   Author: Michal Kukowski
   email: michalkukowski10@gmail.com
   LICENCE: GPL3.0
*/

package myswitch

import (
	"bufio"
	"configs"
	"fmt"
	"os"
	"strconv"
	"sync"
)

// Switch - switch "protected" structure
type Switch struct {
	id       int
	stayTime float64
	edges    []int
	curEdge  int
	free     bool
	mutex    sync.Mutex
}

// ASwitches - array of switches
type ASwitches struct {
	switches  []*Switch
	curSwitch int
}

// Switches - global array of Switches
var Switches ASwitches

// NewSwitch - create new Switch
/*
   PARAMS
   @IN id - ID
   @IN time - stayTime
   @IN n - size of Edges array
*/
func NewSwitch(id int, time float64, n int) *Switch {
	s := new(Switch)
	s.id = id
	s.stayTime = time
	s.free = true

	s.edges = make([]int, n)
	for i := 0; i < len(s.edges); i++ {
		s.edges[i] = 0
	}

	s.curEdge = 0

	return s
}

// ID - get id
func (s *Switch) ID() int {
	return s.id
}

// StayTime - get stayTime
func (s *Switch) StayTime() float64 {
	return s.stayTime
}

// Edges - get Edges
func (s *Switch) Edges() []int {
	return s.edges
}

// SetID - set id
func (s *Switch) SetID(id int) {
	s.id = id
}

// SetStayTime - set stay time
func (s *Switch) SetStayTime(time float64) {
	s.stayTime = time
}

// InsertEdge - add edge to array
func (s *Switch) InsertEdge(edge int) {
	if s.curEdge < len(s.edges) {
		s.edges[s.curEdge] = edge
		s.curEdge++
	}
}

// Free - set Switch as FREE
func (s *Switch) Free() {
	s.mutex.Unlock()
	s.free = true
}

// Busy - set switch as BUSY
func (s *Switch) Busy() {
	s.mutex.Lock()
	s.free = false
}

// isFree - is switch free ?
func (s *Switch) isFree() bool {
	return s.free
}

// Show - show Switch
func (s *Switch) Show() {
	fmt.Println("Switch:")
	fmt.Printf("ID: %d\n", s.id)
	fmt.Printf("StayTime: %f\n", s.stayTime)

	if s.free {
		fmt.Println("State: FREE")
	} else {
		fmt.Println("State: BUSY")
	}

	fmt.Print("Edges: [")
	for i := 0; i < len(s.edges); i++ {
		if s.edges[i] != 0 {
			fmt.Printf("%d ", s.edges[i])
		}
	}
	fmt.Printf("]\n\n")
}

// NewSwitches - create array with Switches
func (s *ASwitches) NewSwitches(n int) {
	s.switches = make([]*Switch, n)
	s.curSwitch = 0
}

// Insert - insert Switch to array
func (s *ASwitches) Insert(sw *Switch) {
	if s.curSwitch < len(s.switches) {
		s.switches[s.curSwitch] = sw
		s.curSwitch++
	}
}

// Switches - get switches
func (s *ASwitches) Switches() []*Switch {
	return s.switches
}

// GetSwitchByID - get Switch by ID
func (s *ASwitches) GetSwitchByID(id int) *Switch {
	return s.switches[id-1]
}

// Show - show all Switches
func (s *ASwitches) Show() {
	fmt.Println("ALL SWITCHES")

	for i := 0; i < len(s.switches); i++ {
		s.switches[i].Show()
	}

	fmt.Println("")
}

// Load - load Switches from file
func (s *ASwitches) Load() {
	file, _ := os.Open("../configs/switches.txt")
	scanner := bufio.NewScanner(file)

	/* SKIP ALL COMMENTS */
	for scanner.Scan() && scanner.Text()[0] == '#' {
	}

	/* for each line ( switch ) DO */
	for i := 0; i < configs.Conf.NumSwitches(); i++ {
		line := scanner.Text()

		/* Start from begining */
		oc := 0
		c := 0

		/* find ID value */
		for line[c] != ';' {
			c++
		}

		/* Get ID value */
		id, _ := strconv.Atoi(line[oc:c])
		c++
		oc = c

		/* Get StayTime */
		stayTime, _ := strconv.ParseFloat(line[oc:len(line)], 64)

		/* Create Switch and Insert to Globa array */
		sw := NewSwitch(id, stayTime, configs.Conf.NumTracks())
		s.Insert(sw)

		scanner.Scan()
	}
}
