using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookAtPlayer : MonoBehaviour
{
    public GameObject player;
    private Vector3 target;

    // Start is called before the first frame update
    void Start()
    {
        if(player == null)
        {
            player = FindObjectOfType<CharacterScript>().gameObject;
        }
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        target = player.transform.position;
        target.y = transform.position.y;
        transform.LookAt(target);
    }
}
