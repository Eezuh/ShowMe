using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class BuddyScript : MonoBehaviour
{
    private NavMeshAgent agent;
    public GameObject player;
    // Start is called before the first frame update
    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        if(player == null)
        {
            player = FindObjectOfType<CharacterScript>().gameObject;
        }
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        agent.SetDestination(player.transform.position);
    }
}
