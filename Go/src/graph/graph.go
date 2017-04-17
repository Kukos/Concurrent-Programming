/*
   This Package contains funtion to parse file to graph
   Author: Michal Kukowski
   email: michalkukowski10@gmail.com
   LICENCE: GPL3.0
*/

package graph

import (
	"bufio"
	"configs"
	"os"
	"strconv"
	"track"
	"myswitch"
)

// Load - load graph from file
func Load() {
	file, _ := os.Open("../configs/graph.txt")
	scanner := bufio.NewScanner(file)

	/* SKIP ALL COMMENTS */
	for scanner.Scan() && scanner.Text()[0] == '#' {
	}

	/* for each line ( track ) DO */
	for i := 0; i < configs.Conf.NumTracks(); i++ {
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
		c = c + 2
		oc = c

		t := track.Tracks.GetTrackByID(id)

		/* Parse Vers */
		for line[c-1] != ']' {

			/* get single switch id */
			for line[c] != ';' && line[c] != ']' {
				c++
			}

			s, _ := strconv.Atoi(line[oc:c])
			c++
			oc = c

			t.InsertVer(s)

		}
		scanner.Scan()
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
		c = c + 2
		oc = c

		s := myswitch.Switches.GetSwitchByID(id)

		/* Parse Vers */
		for line[c-1] != ']' {

			/* get single track id */
			for line[c] != ';' && line[c] != ']' {
				c++
			}

			t, _ := strconv.Atoi(line[oc:c])
			c++
			oc = c

			s.InsertEdge(t)

		}
		scanner.Scan()
	}
}
