using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using System;

public class RaftController : MonoBehaviour
{
    private NavMeshAgent _agent;
    public NavMeshAgent agent => _agent;

    //Waypoint network, holds a list with all the waypoints the raft will go to
    public AIWaypointNetwork waypointNetwork = null;
    //keeps track on what waypoint we're at
    private int _currentWaypoint = 0;
    //gets called by the AIWaypoint script to let the raft know it reached the destination
    public Action OnWaypointArrived;

    //fuel stuff: fuelRate is the amount drained, drainCooldown is the time it takes to drain again
    public float maxFuel = 250f;
    public float fuel;
    public float fuelRate = 0.3f;
    public float drainCooldown = 0.5f;

    //Stores the StartRaft coroutine to make sure it gets stopped
    private Coroutine StartRaftCoroutine;

    //Gets the navmesh agent
    private void Awake()
    {
        _agent = GetComponent<NavMeshAgent>();
    }

    //checks if there's a waypoint network assigned, if not it won't move the raft.
    //SetFirstDestination is called to move the raft to the first Waypoint, after that it'll run on it's own
    void Start()
    {
        fuel = maxFuel;
        if (waypointNetwork == null) return;
        SetFirstDestination();
        StartRaftEngine();
        OnWaypointArrived += SetNextDestination;
    }

    //Can call this from another script to add fuel based on fuel on the player
    public void AddFuel(float fuelAmount)
    {
        fuel += fuelAmount;
    }

    //Can call this to stop the raft and turn off the fuel consumption
    public void StopRaftEngine()
    {
        StopCoroutine(StartRaftCoroutine);
        _agent.isStopped = true;
    }

    //Starts the coroutine to drain fuel until there's none left, then stops the raft from moving
    public void StartRaftEngine()
    {
        StartRaftCoroutine = StartCoroutine(DrainFuel());
    }

    //If the pathing breaks for whatever reason, it'll start at the first waypoint again
    private void fixedUpdate()
    {
        if (_agent.isPathStale)
        {
            SetFirstDestination();
        }
    }

    //the DrainFuel Coroutine
    IEnumerator DrainFuel()
    {
        while(fuel > 0)
        {
            fuel -= fuelRate;
            yield return new WaitForSeconds(drainCooldown);
        }
        _agent.isStopped = true;
    }

    //Call this function to move the raft to the start of the waypoint network
    private void SetFirstDestination()
    {
        Transform nextWaypointTransform = waypointNetwork.Waypoints[_currentWaypoint];
        if (nextWaypointTransform != null)
        {
            _agent.destination = nextWaypointTransform.position;
            return;
        }

        _currentWaypoint++;
    }

    //This is called whenever the raft reaches a waypoint
    void SetNextDestination()
    {
        if (!waypointNetwork)
            return;


        int nextWaypoint = (_currentWaypoint + 1 >= waypointNetwork.Waypoints.Count) ? 0 : _currentWaypoint + 1;
        Transform nextWaypointTransform = waypointNetwork.Waypoints[nextWaypoint];
        if (nextWaypointTransform != null)
        {
            _currentWaypoint = nextWaypoint;
            _agent.destination = nextWaypointTransform.position;
            return;
        }

        _currentWaypoint++;
    }
}