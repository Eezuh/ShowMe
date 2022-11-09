using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyGunScript : MonoBehaviour
{
    public GameObject Enemy;
    public EnemyScript EnemyScript;
    public GameObject EnemyProjectile;
    public GameObject ShootingPoint;
    public Transform PlayerAimTarget;

    private void Update()
    {
        if (PlayerAimTarget != null) //for seperate gun movement (fixes bad aiming when player is close to the enemy)
        {
            transform.LookAt(PlayerAimTarget);
        }
    }
    public void Enemy_ShootProjectile()
    {
        GetComponent<AudioSource>().Play();
        GameObject Projectile = Instantiate(EnemyProjectile, transform);
        Projectile.GetComponent<Rigidbody>().AddRelativeForce(new Vector3(0, 0, EnemyScript.shootingVelocity));
    }
}
