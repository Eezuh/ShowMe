using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RaftTriggerScript : MonoBehaviour
{
    public GameObject Raft;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            other.gameObject.transform.SetParent(Raft.transform, true);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            other.gameObject.transform.parent = null;
        }
    }
}
