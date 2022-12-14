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
            GetComponent<AudioSource>().Play();
            collision.gameObject.GetComponent<PuppetScript>().PuppetHealth -= damage;
        }
        if (collision.gameObject.layer == 12)
        {
            GetComponent<AudioSource>().Play();
            collision.gameObject.GetComponent<CapitanoHittableScript>().CaptainHealth -= damage;
        }
        Destroy(this.gameObject);
    }
}
