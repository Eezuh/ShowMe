using System.Collections;
using System.Collections.Generic;
using UnityEngine;



//For some reason, the player 'pushes' the enemy away if they enter the sphere collider slowly, but when they enter it quickly, everything works fine

public class EnemyScript : MonoBehaviour
{
    public GameObject EnemyGun;
    public Transform PlayerAimTarget;
    public float shootingVelocity;
    public GameObject Enemy;

    public float HidingHeightAmount;
    private bool PlayerInRange;

    private void Start()
    {
        PlayerInRange = false; 
        Enemy.transform.Translate(new Vector3(0, HidingHeightAmount, 0));
       
        StartCoroutine(ShootProjectile());
    }
    private void Update()
    {
        if (PlayerAimTarget != null && PlayerInRange == true)
        {
          Enemy.transform.LookAt(PlayerAimTarget);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == 8)  //layer for player
        {
            PlayerInRange = true;
            Enemy.transform.Translate(new Vector3(0, -HidingHeightAmount, 0));
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == 8)  //layer for player
        {
            PlayerInRange = false;
            Enemy.transform.Translate(new Vector3(0, HidingHeightAmount, 0));
        }
    }

    private IEnumerator ShootProjectile() //shoots a projectile every 4 seconds
    {
        yield return new WaitForSeconds(2f);
        if (PlayerInRange)
        {
            EnemyGun.GetComponent<EnemyGunScript>().Enemy_ShootProjectile();
        }
        StartCoroutine(ShootProjectile());
    }
}
