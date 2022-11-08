using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class BuddyScript : MonoBehaviour
{
    private Animator animator;
    private NavMeshAgent agent;
    public GameObject player;
    // Start is called before the first frame update
    void Start()
    {
        animator = GetComponent<Animator>();
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
        if(agent.velocity.magnitude > 0)
        {
            animator.SetBool("ismoving", true);
        }
        else
        {
            animator.SetBool("ismoving", false);
        }
    }
}
