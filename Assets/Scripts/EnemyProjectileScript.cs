using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyProjectileScript : MonoBehaviour
{
    public float damage;

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.layer == 8)
        {
            other.gameObject.GetComponent<CharacterScript>().health -= damage;
        }

        Destroy(this.gameObject);
    }
}
