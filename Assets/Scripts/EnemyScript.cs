using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


//For some reason, the player 'pushes' the enemy away if they enter the sphere collider slowly, but when they enter it quickly, everything works fine

public class EnemyScript : MonoBehaviour
{
    public GameObject EnemyGun;
    public Transform PlayerAimTarget;
    public float shootingVelocity;
    public GameObject Enemy;
    public float EnemyHealth;

    public float HidingHeightAmount;
    private bool PlayerInRange;

    public Animator TentacleAnimator;
    public GameObject Puppet;
    private bool dead;

    public Image healthImage;
    public AudioClip dieClip;

    private void Start()
    {
        PlayerInRange = false;
        //Enemy.transform.Translate(new Vector3(0, HidingHeightAmount, 0));

        StartCoroutine(ShootProjectile());
        TentacleAnimator = Enemy.GetComponent<Animator>();
        Puppet.GetComponent<PuppetScript>().PuppetHealth = EnemyHealth;
        dead = false;
    }

    private void Update()
    {
        if (PlayerAimTarget != null && PlayerInRange == true)
        {
            Enemy.transform.LookAt(PlayerAimTarget);
            Enemy.transform.eulerAngles = new Vector3(0, transform.eulerAngles.y, 0);
        }

        healthImage.fillAmount = Puppet.GetComponent<PuppetScript>().PuppetHealth / EnemyHealth;

        if (Puppet.GetComponent<PuppetScript>().PuppetHealth <= 0)
        {
            if (dead == false)
            {
                TentacleAnimator.SetTrigger("Hide");
                StartCoroutine(Die());
                dead = true;
                RaftController raftCtrl = FindObjectOfType<RaftController>();
                if (raftCtrl.isStopped)
                {
                    raftCtrl.StartRaftEngine();
                }
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == 8)  //layer for player
        {
            PlayerInRange = true;
            TentacleAnimator.SetTrigger("Emerge");
            GetComponent<AudioSource>().Play();
            //Enemy.transform.Translate(new Vector3(0, -HidingHeightAmount, 0));
        }else if (other.gameObject.layer == 11)
        {
            if (!other.GetComponent<RaftController>().isStopped)
            {
                other.GetComponent<RaftController>().StopRaftEngine();
            }
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == 8)  //layer for player
        {
            PlayerInRange = false;
            GetComponent<AudioSource>().Play();
            TentacleAnimator.SetTrigger("Hide");
            //Enemy.transform.Translate(new Vector3(0, HidingHeightAmount, 0));
        }
    }

    private IEnumerator ShootProjectile() //shoots a projectile every 2 seconds
    {
        yield return new WaitForSeconds(1f);
        if (PlayerInRange && !dead)
        {
            EnemyGun.GetComponent<EnemyGunScript>().Enemy_ShootProjectile();
        }
        StartCoroutine(ShootProjectile());
    }

    private IEnumerator Die()
    {
        GetComponent<AudioSource>().clip = dieClip;
        GetComponent<AudioSource>().Play();
        yield return new WaitForSeconds(2f);
        Destroy(Enemy);
    }
}
