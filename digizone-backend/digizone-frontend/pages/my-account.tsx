/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-explicit-any */
import Router from 'next/router';
import React, { useContext, useEffect } from 'react';
import {
	Button,
	Card,
	Dropdown,
	DropdownButton,
	Form,
	Nav,
	Tab,
	Table,
} from 'react-bootstrap';
import { Col, Row } from 'react-bootstrap';
import StarRatingComponent from 'react-star-rating-component';
import { useToasts } from 'react-toast-notifications';
import AccountDetails from '../components/MyAccount/AccountDetails';
import AllOrders from '../components/MyAccount/AllOrders';
import { Context } from '../context';
// Check this route again 
import { Users } from '../services/user.service'

const MyAccount = () => {
	const { addToast } = useToasts();
	const {
		state: { user },
		dispatch,
	} = useContext(Context);
	useEffect(() => {
		if (!user || !user.email) {
			Router.push('/auth'); // if user already logged in redirect to my account
		}
	}, [user]);

	const logoutHandler = async () => {
		try {
			dispatch({
				type: 'LOGOUT',
				payload: undefined,
			});
			await Users.logoutUser();
			localStorage.removeItem('_digi_user');
			addToast('Logout Successful', {
				appearance: 'success',
				autoDismiss: true,
			});
			Router.push('/auth');
		} catch (error: any) {
			addToast(error.message, {
				appearance: 'error',
				autoDismiss: true,
			});
		}
	};

	return (
		<Tab.Container id='left-tabs-example' defaultActiveKey='first'>
			<Row>
				<Col sm={3}>
					<Nav variant='pills' className='flex-column'>
						<Nav.Item>
							<Nav.Link eventKey='first' href='#'>
								Account Details
							</Nav.Link>
						</Nav.Item>
						<Nav.Item>
							<Nav.Link eventKey='second' href='#'>
								All Orders
							</Nav.Link>
						</Nav.Item>
						{/* <Nav.Item>
							<Nav.Link eventKey='third' href='#'>
								Support tickets
							</Nav.Link>
						</Nav.Item> */}
						<Nav.Item>
							<Nav.Link eventKey='third' href='#' onClick={logoutHandler}>
								Logout
							</Nav.Link>
						</Nav.Item>
					</Nav>
				</Col>
				<Col sm={9}>
					<Tab.Content>
						<Tab.Pane eventKey='first'>
							<AccountDetails
								user={user}
								dispatch={dispatch}
								addToast={addToast}
							/>
						</Tab.Pane>
						<Tab.Pane eventKey='second'>
							<AllOrders />
						</Tab.Pane>
						<Tab.Pane eventKey='third'>
							<div>
								<Button variant='outline-info' className='addReview'>
									Add review
								</Button>
								<div className='reviewInputZone'>
									<Form>
										<Form.Group className='mb-3' controlId='formBasicEmail'>
											<Form.Label>Your Rating</Form.Label>
											<br />
											<StarRatingComponent
												name='rate2'
												editing={true}
												starCount={5}
												value={0}
											/>
										</Form.Group>
										<Form.Group className='mb-3' controlId='formBasicPassword'>
											<Form.Label>Your Review</Form.Label>
											<Form.Control as='textarea' rows={3} />
										</Form.Group>
										<Form.Group
											className='mb-3'
											controlId='formBasicCheckbox'
										></Form.Group>
										<Button variant='primary' type='submit'>
											Submit
										</Button>
									</Form>
								</div>
							</div>
						</Tab.Pane>
					</Tab.Content>
				</Col>
			</Row>
		</Tab.Container>
	);
};

export default MyAccount;
