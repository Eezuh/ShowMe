using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


//For some reason, the player 'pushes' the enemy away if they enter the sphere collider slowly, but when they enter it quickly, everything works fine

public class CapitanoScript : MonoBehaviour
{
    public GameObject Enemy;
    public Transform PlayerAimTarget;
    public float EnemyHealth;

    private bool PlayerInRange;

    private bool dead;

    public Image healthImage;
    public AudioClip dieClip;

    private void Start()
    {
        PlayerInRange = false;
        Enemy.GetComponent<CapitanoHittableScript>().CaptainHealth = EnemyHealth;

        dead = false;
    }

    private void Update()
    {
        if (PlayerAimTarget != null && PlayerInRange == true)
        {
            Enemy.transform.LookAt(PlayerAimTarget);
            Enemy.transform.eulerAngles = new Vector3(0, transform.eulerAngles.y, 0);
        }

        healthImage.fillAmount = Enemy.GetComponent<CapitanoHittableScript>().CaptainHealth / EnemyHealth;

        if (Enemy.GetComponent<CapitanoHittableScript>().CaptainHealth <= 0)
        {
            dead = true;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == 8)  //layer for player
        {
            PlayerInRange = true;
            GetComponent<AudioSource>().Play();
            
        }
        else if (other.gameObject.layer == 11)
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
        }
    }

    private IEnumerator Die()
    {
        GetComponent<AudioSource>().clip = dieClip;
        GetComponent<AudioSource>().Play();
        yield return new WaitForSeconds(2f);
        Destroy(Enemy);
    }
}
