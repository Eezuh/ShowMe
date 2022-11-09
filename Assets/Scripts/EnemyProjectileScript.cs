using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyProjectileScript : MonoBehaviour
{
    public float damage;

    private void Start()
    {
        StartCoroutine(DeleteProjectile());
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.layer == 8)
        {
            other.gameObject.GetComponentInParent<CharacterScript>().health -= damage;
            other.gameObject.GetComponentInParent<CharacterScript>().source.clip = other.gameObject.GetComponentInParent<CharacterScript>().damageClip;
            other.gameObject.GetComponentInParent<CharacterScript>().source.Play();
            Destroy(this.gameObject);
        }
    }
    
    IEnumerator DeleteProjectile()
    {
        yield return new WaitForSeconds(15);
        Destroy(gameObject);
    }
}
