using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIWaypoint : MonoBehaviour
{
    //Checks if the raft entered the area of the waypoint, then invokes an action that triggers the SetNextDestination() function on RaftController.
    private void OnTriggerEnter(Collider other)
    {
        if (other.GetComponent<RaftController>())
        {
            other.GetComponent<RaftController>().OnWaypointArrived.Invoke();
        }
    }
}
