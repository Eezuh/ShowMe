using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterScript : MonoBehaviour
{
    private float health;
    public float MaxWaterFuelAmount;
    private float CurrentWaterFuelAmount;
    private float WaterFuelPercentage;
    private float RaftFuelHolding;

    public GameObject PlayerGun;
    public GameObject FirePoint;
    public GameObject MineralVacuum;

    public GameObject OnHandPos;
    public GameObject OffHandPos;

    public float ShortBlastDamage;
    public float StreamDamagePerSecond;

    public float ShortBlastCost;
    public float StreamAttackCostPerSecond;

    public float MaxBlastAttackVelocity;

    private float HoldStartTime;
    public float StreamDelay;
    private bool AttackIsStream;

    public GameObject Attack_Blast;
    public GameObject Attack_Stream;

    private void Start()
    {
        InitializeItemPosition();
        CurrentWaterFuelAmount = MaxWaterFuelAmount;
    }

    private void Update()
    {
        CalculateWaterFuelPercentage();
        Debug.Log(WaterFuelPercentage);

        if (Input.GetKeyDown(KeyCode.Mouse0))
        {
            HoldStartTime = Time.time;
        }

        if (Input.GetKey(KeyCode.Mouse0))
        {
            if (Time.time >= HoldStartTime + StreamDelay)
            {
                AttackIsStream = true;
                FireStream();
                Debug.Log("Stream Attack");
            }
        }

        if (Input.GetKeyUp(KeyCode.Mouse0))
        {
            if (AttackIsStream == false)
            {
                FireShortBlast();
                Debug.Log("shortblast");
            }
            AttackIsStream = false;
        }

        if (Input.GetKeyDown(KeyCode.Mouse1))
        {
            AttackIsStream = false;
            SwitchItems();
            //switch weapons
        }

        if (Input.GetKey(KeyCode.Mouse1))
        {
            //zuckk
            Debug.Log("sucking");
        }

        if (Input.GetKeyUp(KeyCode.Mouse1))
        {
            SwitchItems();
        }
    }

    private void FireShortBlast() //Dpesnt work yet :(((
    {
        //fire wit power based on available fuel;
        //lower fuel amount

        GameObject Projectile = Instantiate(Attack_Blast, FirePoint.transform);
        Projectile.GetComponent<Rigidbody>().AddRelativeForce(new Vector3(0, 0, MaxBlastAttackVelocity*WaterFuelPercentage));
        CurrentWaterFuelAmount -= ShortBlastCost;

    }

    private void FireStream()
    {
        Attack_Stream.transform.localScale =  new Vector3(0, Attack_Stream.transform.localScale.y);
        GameObject Projectile = Instantiate(Attack_Stream, FirePoint.transform);
        CurrentWaterFuelAmount -= StreamAttackCostPerSecond;
        //shoot stream every time function is called (once a second or so) and calculate distance based on fuel amount every time -> IENumerator probs
        //lower fuel amount every time
    }

    private void InitializeItemPosition()
    {
        PlayerGun.transform.position = OnHandPos.transform.position;
        PlayerGun.transform.rotation = OnHandPos.transform.rotation;
        MineralVacuum.transform.position = OffHandPos.transform.position;
        MineralVacuum.transform.rotation = OffHandPos.transform.rotation;
    }

    private void SwitchItems()
    {
        if(PlayerGun.transform.position == OnHandPos.transform.position)
        {
            PlayerGun.transform.position = OffHandPos.transform.position;
            MineralVacuum.transform.position = OnHandPos.transform.position;
            PlayerGun.transform.rotation = OffHandPos.transform.rotation;
            MineralVacuum.transform.rotation = OnHandPos.transform.rotation;
        }
        else
        {
            PlayerGun.transform.position = OnHandPos.transform.position;
            MineralVacuum.transform.position = OffHandPos.transform.position;
            PlayerGun.transform.rotation = OnHandPos.transform.rotation;
            MineralVacuum.transform.rotation = OffHandPos.transform.rotation;
        }
    }

    private void CalculateWaterFuelPercentage()
    {
        WaterFuelPercentage = CurrentWaterFuelAmount / MaxWaterFuelAmount;
    }
}

