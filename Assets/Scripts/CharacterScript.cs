using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class CharacterScript : MonoBehaviour
{
    public float health;
    public float maxHealth;
    public float MaxWaterFuelAmount;
    public float CurrentWaterFuelAmount;
    public float MaxRaftFuelHolding;
    public float RaftFuelHolding;
    public float RaftFuelDepositSpeed;

    public GameObject PlayerGun;
    public GameObject FirePoint;
    public GameObject MineralVacuum;

    private GameObject currentGun;

    public GameObject OnHandPos;
    public GameObject OffHandPos;

    public float ShortBlastDamage;

    public float ShortBlastCost;

    public float MaxBlastAttackVelocity;

    public GameObject Attack_Blast;

    private bool InOutcropRange;
    private GameObject CurrentOutcrop;
    public float SuckSpeed;

    private bool InCarbonatorRange;
    public float WaterFuelChargeAmount;

    private bool InRefuelRange;

    public GameObject PlayerCamera;

    public GameObject Raft;

    public Image healthImage;
    public Image vacuumImage;
    public Image gunImage;
    public Image raftImage;
    public TMP_Text interactText;

    public AudioClip vacuumClip;
    public AudioClip damageClip;
    public AudioSource source;

    private void Start()
    {
        health = maxHealth;
        source = GetComponent<AudioSource>();
        InitializeItemPosition();
        CurrentWaterFuelAmount = MaxWaterFuelAmount;
        InOutcropRange = false;
        RaftFuelHolding = 0;
        Raft = FindObjectOfType<RaftController>().gameObject;
        PlayerGun.transform.SetParent(PlayerCamera.transform, true);
        currentGun = PlayerGun;
        SetUI();
    }

    private void SetUI()
    {
        if(healthImage == null)
        {
            healthImage = GameObject.Find("PlayerHealth").GetComponent<Image>();
        }
        if (vacuumImage == null)
        {
            vacuumImage = GameObject.Find("VacuumFill").GetComponent<Image>();
        }
        if (gunImage == null)
        {
            gunImage = GameObject.Find("GunFill").GetComponent<Image>();
        }
        if (raftImage == null)
        {
            raftImage = GameObject.Find("RaftFill").GetComponent<Image>();
        }
        if (interactText == null)
        {
            interactText = GameObject.Find("InteractTex").GetComponent<TMP_Text>();
        }
    }

    private void Update()
    {
        if (Input.GetKey(KeyCode.R) && currentGun == PlayerGun)
        {
            if (InCarbonatorRange) 
            { 
                Carbonate();
            }
        }

        if (Input.GetKeyDown(KeyCode.Mouse0) && currentGun == PlayerGun)
        {
            FireShortBlast();
        }

        if (Input.GetKey(KeyCode.Mouse1) && currentGun == MineralVacuum)
        {
            if (!source.isPlaying)
            {
                source.clip = vacuumClip;
                source.Play();
            }
            SuckMineralFuel();
        }

        if (Input.GetKey(KeyCode.E))
        {
            if (InRefuelRange)
            {
                DepositRaftFuel();
            }
        }

        if (Input.GetKeyDown(KeyCode.Q))
        {
           SwitchItems(); 
        }

        UpdateUI();
    }

    private void UpdateUI()
    {
        healthImage.fillAmount = health / maxHealth;
        vacuumImage.fillAmount = RaftFuelHolding / MaxRaftFuelHolding;
        gunImage.fillAmount = CurrentWaterFuelAmount / MaxWaterFuelAmount;
        raftImage.fillAmount = Raft.GetComponent<RaftController>().fuel / Raft.GetComponent<RaftController>().maxFuel;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == 6) //oitcrop
        {
            InOutcropRange = true;
            CurrentOutcrop = other.gameObject;
            interactText.text = "Hold RMB while holding the mineral collector to collect the crop!";
        }
        else if (other.gameObject.layer == 7) //carbonator
        {
            InCarbonatorRange = true;
            interactText.text = "Hold R while holding your gun to carbonate your ammo!";
        }else if(other.gameObject.layer == 10) //refuel
        {
            InRefuelRange = true;
            interactText.text = "Hold E to refuel the raft!";
        }
    }

    private void OnTriggerExit(Collider other) //see if this works with edstroying the object
    {
        if (other.gameObject.layer == 6)
        {
            if (CurrentOutcrop.GetComponent<OutcropScript>().FuelInOutcrop <= 0)
            {
                CurrentOutcrop.GetComponent<OutcropScript>().Despawn();
            }
            InOutcropRange = false;
            CurrentOutcrop = null;
        }
        else if (other.gameObject.layer == 7)
        {
            InCarbonatorRange = false;
        }else if(other.gameObject.layer == 10)
        {
            InRefuelRange = false;
        }
        interactText.text = "";
    }

    private void FireShortBlast()
    {
        if(!((CurrentWaterFuelAmount - ShortBlastCost) < 0))
        {
            GameObject Projectile = Instantiate(Attack_Blast, FirePoint.transform.position, FirePoint.transform.rotation);
            Projectile.GetComponent<Rigidbody>().AddRelativeForce(new Vector3(0, 0, MaxBlastAttackVelocity));
            CurrentWaterFuelAmount -= ShortBlastCost;
        }
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
        if(PlayerGun.transform.parent == PlayerCamera.transform)
        {
            PlayerGun.transform.SetParent(transform, true);
            currentGun = MineralVacuum;
            PlayerGun.transform.position = OffHandPos.transform.position;
            MineralVacuum.transform.position = OnHandPos.transform.position;
            PlayerGun.transform.rotation = OffHandPos.transform.rotation;
            MineralVacuum.transform.rotation = PlayerCamera.transform.rotation; ;

            MineralVacuum.transform.SetParent(PlayerCamera.transform, true);
        }
        else
        {
            MineralVacuum.transform.SetParent(transform, true);
            currentGun = PlayerGun;
            PlayerGun.transform.position = OnHandPos.transform.position;
            MineralVacuum.transform.position = OffHandPos.transform.position;
            PlayerGun.transform.rotation = PlayerCamera.transform.rotation;
            MineralVacuum.transform.rotation = OffHandPos.transform.rotation;

            PlayerGun.transform.SetParent(PlayerCamera.transform, true);
        }
    }

    private void SuckMineralFuel()
    {
        if (CurrentOutcrop != null)
        {
            if (CurrentOutcrop.GetComponent<OutcropScript>().FuelInOutcrop > 0)
            {
                CurrentOutcrop.GetComponent<OutcropScript>().FuelInOutcrop -= SuckSpeed;
                RaftFuelHolding += SuckSpeed;
            }
        }
    }

    private void Carbonate()
    {
        if (CurrentWaterFuelAmount <= MaxWaterFuelAmount)
        {
            CurrentWaterFuelAmount += WaterFuelChargeAmount;
        }
        else
        {
            CurrentWaterFuelAmount = MaxWaterFuelAmount;
        }   
    }

    private void DepositRaftFuel()
    {
        Debug.Log("Attempting to refuel...");
        if (RaftFuelHolding > 0 && (Raft.GetComponent<RaftController>().fuel + RaftFuelDepositSpeed) <= Raft.GetComponent<RaftController>().maxFuel)
        {
            Debug.Log($"refueling with {RaftFuelHolding} stored...");
            Raft.GetComponent<RaftController>().AddFuel(RaftFuelDepositSpeed);
            RaftFuelHolding -= 2*RaftFuelDepositSpeed;
        }
        else
        {

        }
    }
}

