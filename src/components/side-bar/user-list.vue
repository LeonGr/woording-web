<style lang="sass">

#user-list {
	display: flex;
	flex-direction: column;
	@media (min-width: 768px) {
		min-width: 10rem;
	}

	#users {
		background-color: #388E3C;
		color: #FFFFFF;
		padding-top: .5rem;
		min-height: 0;
		flex: 1;

		a {
			text-decoration: none;
			color: #FFFFFF;
			&:visited {
				color: #FFFFFF;
			}
		}

		p, .list_header {
			padding-left: .5rem;
			padding-top: .25rem;
			padding-bottom: .25rem;
        }

        .user-link-item {
            &:hover {
                background-color: #4CAF50;
            }
		}


		.user-link {
			transition: 0.1s;
		}

		.v-link-active p {
			background-color: #4CAF50;

		}

		@media (min-width: 768px) {
			min-height: 0;
			overflow: auto;

		}
	}

	#add-friend-button {
		background-color: #4CAF50;
		color: white;
		text-align: center;
		font-size: 2rem;
		cursor: pointer;
	}

}

</style>

<template>
	<div id="user-list">
		<div id="users">
			<ul>
				<li class="list_header">YOU</li>

                <li class="user-link-item">
                    <a v-link='{ path: "/" + this.username }'>
                        <p class="user-link">{{ username }}</p>
                    </a>
                </li>

				<li><br></li>
				<li class="list_header">FRIENDS</li>
                <li v-for="friend in friends" class="user-link-item">
                    <a v-link='{ path: "/" + friend.username}'>
                        <p class="user-link">{{ friend.username }}</p>
                    </a>
                </li>
			</ul>
		</div>
		<div id="add-friend-button" v-on:click="addFriend">
			<p>+</p>
		</div>
	</div>
</template>

<script>
import store from '../../store'
import globals from "../../globals";

export default {

	data: function () {
		var username = this.$parent.$route.params.username
		this.fetchFriends(username)

        store.fetchToken().then(response => {
            username = store.username
            this.username = store.username
        }).catch(error => {
        })

		return {
			friends: [],
			username: username
		}
	},

	methods: {
		updateActiveUserHighlight: function() {
			var username = this.$parent.$route.params.username
		},

		addFriend: function() {
			var friendname = prompt('Who would you like to be friends with?')

			store.friendRequest(store.username, friendname).then(response => {
				console.log(response)
			}, response => {
				console.log(response)
			})
		},

		fetchFriends: function(username) {
			var updateFriends = friends => { this.friends = friends }

			store.fetchFriends().then(response => {
                if(!response.friends.length){
                    console.log('no friends')
                }
				updateFriends(response.friends)
			})
		}
	}


}
</script>
