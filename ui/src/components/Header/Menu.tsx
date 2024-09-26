import React, {ChangeEvent, ReactElement, useEffect, useState} from 'react'
import Link from 'next/link'
import loadable from '@loadable/component'
import Logo from '@shared/atoms/Logo'
import UserPreferences from './UserPreferences'
import styles from './Menu.module.css'
import {useRouter} from 'next/router'
import {useMarketMetadata} from '@context/MarketMetadata'
import Button from "@shared/atoms/Button";
import Modal from "@shared/atoms/Modal";
import Input from "@shared/FormInput";
import Loader from "@shared/atoms/Loader";
import {useWeb3} from "@context/Web3";
import {UserRole, UserRoleTitle} from 'src/@types/user';

import {auditorDaoABI, bountyFactoryABI, companyFactoryDaoABI, sbtABI} from '@utils/abi';
import {
    auditorDAOAddresses,
    bountyFactoryAddress,
    companyFactoryDaoAddress,
    hackerSolBoundAddress
} from "../../../app.config";
import Alert from "@shared/atoms/Alert";
import {sleep} from "@utils/index";

const Wallet = loadable(() => import('./Wallet'))

declare type MenuItem = {
    name: string
    link: string
}

function MenuLink({item}: { item: MenuItem }) {
    const router = useRouter()

    const classes =
        router?.pathname === item.link
            ? `${styles.link} ${styles.active}`
            : styles.link

    return (
        <Link key={item.name} href={item.link}>
            <a className={classes}>{item.name}</a>
        </Link>
    )
}


export default function Menu(): ReactElement {
    const {siteContent} = useMarketMetadata()
    const [isDialogOpen, setIsDialogOpen] = useState(false)
    const [isDialogLoaded, setIsDialogLoaded] = useState(false)
    const [companyDaoAddresses, setCompanyDaoAddresses] = useState([])
    const [isSignupOpen, setIsSignupOpen] = useState(false)
    const [userRole, setUserRole] = useState(UserRoleTitle.Unknown);

    const [bugBountyTitle, setBugBountyTitle] = useState("");
    const [selectedCompany, setSelectedCompany] = useState("");
    const [selectedDao, setSelectedDao] = useState(auditorDAOAddresses[0]);
    const [selectedRole, setSelectedRole] = useState(UserRoleTitle.Unknown);
    const [bugBountyDescription, setBugBountyDescription] = useState("")
    const [isAlert, setIsAlert] = useState({})
    const {accountId, web3, web3Loading, web3Provider} = useWeb3()

    async function getDappRole() {
        console.log("Getting user dAPP role");

        let auditorDaoContract = new web3.eth.Contract(auditorDaoABI, selectedDao, {
            from: accountId,
        });
        
        let sbtAddress = await auditorDaoContract.methods.hackerSBT().call();
        
        console.log("Got SBT Address ", sbtAddress);
        let sbtContract = new web3.eth.Contract(sbtABI, sbtAddress, {
            from: accountId,
        });

        try {
            let role: string = await sbtContract.methods.getUserRole(accountId).call();

            let intRole: number = parseInt(role, 10);
            intRole = 1;

            switch (intRole) {
                case UserRole.Hacker:
                    setUserRole(UserRoleTitle.Hacker);
                    break;
                
                case UserRole.Company:
                    setUserRole(UserRoleTitle.Company);
                    break;
                
                default: // Captures NaN as well
                    setUserRole(UserRoleTitle.Unknown);

            }
            console.log("Set User role");

        } catch(e) {
            console.log("User role not set yet");
            setUserRole(UserRoleTitle.Unknown);

        }
    }


    async function submitRoleSubmission(e) {
        e.preventDefault();
        setIsDialogLoaded(false);

        try{ 
            const contract = new web3.eth.Contract(auditorDaoABI, selectedDao, {
                from: accountId
            });

            const registerResponse = await contract.methods.registerAsHacker().send({from: accountId});
            console.log("Register response", registerResponse);
            setIsAlert(
                {
                    text: "Hacker Profile Created",
                    type: "success",
                }
            )
        
        } catch(e) {
            console.log(e);
            setIsAlert(
                {
                    text: "Failed to Create Hacker Profile",
                    type: "failure",

                }
            )
        }
        
        setIsDialogLoaded(true);
    }

    async function submitDetails(e) {
        e.preventDefault();
        setIsDialogLoaded(false);
        const contract = new web3.eth.Contract(bountyFactoryABI, bountyFactoryAddress, {
            from: accountId
        });

        console.log("Address", selectedCompany);
        try{
            const resCreate = await contract.methods.addNewBounty(selectedCompany, selectedCompany, Math.floor(Date.now() + 3600),
                "testtttttttesttttttttesttttttt", 122, bugBountyTitle, bugBountyDescription).send({from: accountId});

            console.log(resCreate);
            setIsAlert({
                text: "Bug Bounty Created",
                type: "success"
            });
        }
        catch (e) {
            console.log(e);
            setIsAlert({
                text: "Couldn't create BugBounty",
                type: "error"
            });
        }
        setIsDialogLoaded(true);
        await sleep(2000);
        window.location.reload();
    }

    async function getContractAddress(){
        setIsDialogOpen(true);
        let companyFactoryContract = new web3.eth.Contract(companyFactoryDaoABI, companyFactoryDaoAddress, {
            from: accountId
        });

        let displayList = ["select"].concat(await companyFactoryContract.methods.getCompanyDaos().call());

        setCompanyDaoAddresses(displayList);
        setIsDialogLoaded(true);

    }

    useEffect(() => {

        if (!web3Loading && accountId){
            getDappRole();
        }
    }, [web3, web3Loading])

    return (
        <nav className={styles.menu}>
            <Link href="/">
                <a className={styles.logo}>
                    <Logo noWordmark/>
                    <h1 className={styles.title}>{siteContent?.siteTitle}</h1>
                </a>
            </Link>

            <ul className={styles.navigation}>
                {/*{siteContent?.menu.map((item: MenuItem) => (*/}
                {/*    <li key={item.name}>*/}
                {/*        <MenuLink item={item}/>*/}
                {/*    </li>*/}
                {/*))}*/}

                {accountId && (userRole === UserRoleTitle.Company) ? <li key="bug-bounty">
                    <a className={styles.link} onClick={() => getContractAddress()}>
                        Create Bug Bounty
                    </a>
                    <Modal
                        title={"New Bug Bounty"}
                        isOpen={isDialogOpen}
                        onToggleModal={() => setIsDialogOpen(false)}
                    >
                        <p>
                            Please enter the relevant Bounty fields in below and hit submit once ready to deploy.
                        </p>
                        <div className={styles.meta}>

                            {isAlert.text ? <Alert text={isAlert.text} state={isAlert.type} /> : ""}
                            <br/><br/>
                            {!isDialogLoaded ? <Loader /> : <form>
                                <Input
                                    name="company"
                                    label="Company Dao"
                                    help="The Company DAO you want to create the bounty under"
                                    type="select"
                                    value={selectedCompany}
                                    options={companyDaoAddresses}
                                    onChange={(e: ChangeEvent<HTMLSelectElement>) =>
                                        setSelectedCompany(e.target.value)
                                    }
                                    size="small"
                                />

                                <Input
                                    name="title"
                                    label="Bug Bounty program"
                                    help="The title of the Bug Bounty Program"
                                    type="text"
                                    value={bugBountyTitle}
                                    onChange={(e: ChangeEvent<HTMLSelectElement>) =>
                                        setBugBountyTitle(e.target.value)
                                    }
                                    size="small"
                                />
                                <Input
                                    name="description"
                                    label="Bug Bounty program description"
                                    help="The Description of the Bug Bounty Program"
                                    type="textarea"
                                    value={bugBountyDescription}
                                    onChange={(e: ChangeEvent<HTMLSelectElement>) =>
                                        setBugBountyDescription(e.target.value)
                                    }
                                    size="small"
                                />

                                <Button style="text" size="small" onClick={(e) => submitDetails(e)}>
                                    Submit New Program
                                </Button>
                            </form>
                            }
                        </div>
                    </Modal>
                </li> : <></>}

                {accountId && (userRole === UserRoleTitle.Unknown) ? <li key="signup">
                    <a className={styles.link} onClick={() => setIsSignupOpen(true)}>
                        Signup!
                    </a>
                    <Modal
                        title={"Signup To Join the WhiteHat DAO!"}
                        isOpen={isSignupOpen}
                        onToggleModal={() => setIsSignupOpen(false)}
                    >

                        <div className={styles.meta}>
                            {isAlert.text ? <Alert text={isAlert.text} state={isAlert.type} /> : ""}

                            <br/><br/>
                            <p> Please specify the role which you'd like an SBT minted for and press Submit</p>
                            {!isDialogLoaded ? <Loader /> : <form>
                                <Input
                                    name="auditor Dao"
                                    label="Auditor Dao"
                                    help="The Auditor DAO you want to register under"
                                    type="select"
                                    value={selectedDao}
                                    options={["select"].concat(auditorDAOAddresses)}
                                    onChange={(e: ChangeEvent<HTMLSelectElement>) =>
                                        setSelectedDao(e.target.value)
                                    }
                                    size="small"
                                />
                                <Input
                                    name="role"
                                    label="Role"
                                    help="The Role which you are applying for"
                                    type="select"
                                    value={selectedRole}
                                    options={["select", "hacker"]} // TODO - Pass in other roles
                                    onChange={(e: ChangeEvent<HTMLSelectElement>) =>
                                        setSelectedRole(e.target.value)
                                    }
                                    size="small"
                                />
                                <Button style="text" size="small" onClick={(e) => submitRoleSubmission(e)}>
                                    Submit
                                </Button>
                            </form>
                            }
                        </div>
                    </Modal>
                </li> : <></>}
                {userRole !== UserRoleTitle.Unknown ?
                    <li key="125">
                    <a className={styles.link}>
                        [{userRole}]
                    </a>
                </li> : <></>}

            </ul>

            <div className={styles.actions}>
                {/*<SearchBar />*/}
                {/*<Networks />*/}
                <Wallet/>
                <UserPreferences/>
            </div>
        </nav>
    )
}
