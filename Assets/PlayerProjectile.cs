using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerProjectile : MonoBehaviour
{
    public float damage;
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.layer == 9)
        {
            collision.gameObject.GetComponent<PuppetScript>().PuppetHealth -= damage;
        }
        Destroy(this.gameObject);
    }
}
